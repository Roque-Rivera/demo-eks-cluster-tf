# VPC Module Outputs
# ================

# VPC Outputs
# ----------

output "vpc_id" {
  description = "The ID of the VPC. Used by other modules and resources that need to be created within this VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC. Used for security group rules and network planning"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
# ------------

output "public_subnet_ids" {
  description = "List of IDs of public subnets. Used for resources that need public internet access (e.g., load balancers)"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "List of IDs of private application subnets. Used for EKS nodes and other application resources"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "List of IDs of private database subnets. Used for RDS and other data layer resources"
  value       = aws_subnet.private_db[*].id
}

# Route Table Outputs
# ----------------

output "public_route_table_id" {
  description = "ID of the public route table. Used for custom route management and network analysis"
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "List of IDs of private application route tables. Used for custom route management"
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_ids" {
  description = "List of IDs of private database route tables. Used for custom route management"
  value       = aws_route_table.private_db[*].id
}

# NAT Gateway Outputs
# ----------------

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs. Used for monitoring and route table management"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of NAT Gateways. Used for whitelisting and monitoring"
  value       = aws_eip.nat[*].public_ip
}

# VPC Endpoint Outputs
# -----------------

output "vpc_endpoint_s3_id" {
  description = "ID of S3 VPC endpoint. Used for monitoring and route table association"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_ecr_api_id" {
  description = "ID of ECR API VPC endpoint. Used for monitoring and security group management"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ID of ECR DKR VPC endpoint. Used for monitoring and security group management"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "vpc_endpoint_ssm_id" {
  description = "ID of SSM VPC endpoint. Used for monitoring and security group management"
  value       = aws_vpc_endpoint.ssm.id
}

# Security Group Outputs
# -------------------

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC endpoints. Used for adding additional security rules"
  value       = aws_security_group.vpc_endpoints.id
}

# Network Configuration Outputs
# --------------------------

output "availability_zones" {
  description = "List of availability zones used in the VPC. Used for reference and resource distribution"
  value       = var.availability_zones
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks. Used for network planning and security group rules"
  value       = var.public_subnet_cidrs
}

output "private_app_subnet_cidrs" {
  description = "List of private application subnet CIDR blocks. Used for network planning and security group rules"
  value       = var.private_app_subnet_cidrs
}

output "private_db_subnet_cidrs" {
  description = "List of private database subnet CIDR blocks. Used for network planning and security group rules"
  value       = var.private_db_subnet_cidrs
}

# Additional Network Information
# ---------------------------

output "vpc_default_network_acl_id" {
  description = "The ID of the default network ACL. Used for custom NACL rules if needed"
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the default VPC security group. Used for security group rule management"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_enable_dns_support" {
  description = "Whether DNS support is enabled. Used for troubleshooting and verification"
  value       = aws_vpc.main.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled. Used for troubleshooting and verification"
  value       = aws_vpc.main.enable_dns_hostnames
}

# Note: These outputs provide comprehensive information about the VPC
# and its components, enabling other modules and resources to reference
# the necessary information for their configuration. The descriptions
# explain both what each output contains and how it might be used.
