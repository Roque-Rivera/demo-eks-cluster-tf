# VPC Module Main Configuration
# ===========================

# Virtual Private Cloud (VPC)
# --------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Required for EKS and other AWS services
  enable_dns_support   = true  # Required for EKS and other AWS services

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# Internet Gateway
# ---------------
# Required for public subnets to access internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# Public Subnets (Web Tier)
# ------------------------
# These subnets will host public-facing resources like load balancers
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # Auto-assign public IPs to resources in these subnets

  tags = merge(
    var.tags,
    {
      Name                                = "${var.project_name}-public-${var.availability_zones[count.index]}"
      "kubernetes.io/role/elb"           = "1"  # Required for EKS to identify public subnets for ALBs
      "kubernetes.io/cluster/${var.project_name}" = "shared"  # Required for EKS cluster resource discovery
    }
  )
}

# Private Subnets (App Tier)
# -------------------------
# These subnets will host EKS nodes and other application resources
resource "aws_subnet" "private_app" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name                                = "${var.project_name}-private-app-${var.availability_zones[count.index]}"
      "kubernetes.io/role/internal-elb"   = "1"  # Required for EKS to identify private subnets for internal ALBs
      "kubernetes.io/cluster/${var.project_name}" = "shared"  # Required for EKS cluster resource discovery
    }
  )
}

# Private Subnets (DB Tier)
# ------------------------
# These subnets will host databases and other data layer resources
resource "aws_subnet" "private_db" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-db-${var.availability_zones[count.index]}"
    }
  )
}

# Elastic IPs for NAT Gateways
# ---------------------------
# Required for NAT Gateways to maintain a stable public IP
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-eip-${count.index + 1}"
    }
  )
}

# NAT Gateways
# -----------
# Enables private subnet resources to access internet while remaining private
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id  # NAT Gateways must be in public subnets

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]  # Ensure IGW exists first
}

# Route Tables
# -----------

# Public Route Table
# For public subnets - routes traffic to internet through IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

# Private App Route Tables
# For private app subnets - routes traffic to internet through NAT Gateway
resource "aws_route_table" "private_app" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-app-rt-${var.availability_zones[count.index]}"
    }
  )
}

# Private DB Route Tables
# For private db subnets - routes traffic to internet through NAT Gateway
resource "aws_route_table" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-db-rt-${var.availability_zones[count.index]}"
    }
  )
}

# Route Table Associations
# ----------------------

# Public Subnet Associations
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Subnet Associations
resource "aws_route_table_association" "private_app" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private DB Subnet Associations
resource "aws_route_table_association" "private_db" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}

# VPC Endpoints
# ------------
# Enable private access to AWS services without internet

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-s3-endpoint"
    }
  )
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecr-api-endpoint"
    }
  )
}

# ECR Docker Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecr-dkr-endpoint"
    }
  )
}

# SSM Interface Endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ssm-endpoint"
    }
  )
}

# Security Group for VPC Endpoints
# ------------------------------
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # Allow HTTPS access from within VPC
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc-endpoints-sg"
    }
  )
}
