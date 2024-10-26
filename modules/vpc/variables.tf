# VPC Module Variables
# ==================

# Basic Configuration Variables
# ---------------------------

variable "region" {
  description = "AWS region where the VPC will be created. Used for VPC endpoint service names"
  type        = string
}

variable "project_name" {
  description = "Name of the project. Used as a prefix for all resources to ensure unique naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Should be a /16 network to provide enough IP addresses for all subnets"
  type        = string
}

# Network Configuration Variables
# ----------------------------

variable "availability_zones" {
  description = "List of availability zones for high availability. Should be at least 2 AZs for redundancy"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public (web tier) subnets. Should be /20 networks within the VPC CIDR"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application tier subnets. Should be /20 networks within the VPC CIDR"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database tier subnets. Should be /20 networks within the VPC CIDR"
  type        = list(string)
}

# Tagging Variables
# ---------------

variable "tags" {
  description = "Map of tags to apply to all VPC resources for better organization and cost tracking"
  type        = map(string)
  default     = {}
}

# VPC Feature Flags
# ---------------

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC. Required for EKS and many AWS services"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC. Required for EKS and many AWS services"
  type        = bool
  default     = true
}

# NAT Gateway Configuration
# -----------------------

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ. Reduces costs but decreases availability"
  type        = bool
  default     = false
}

# VPC Endpoint Configuration
# ------------------------

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC Endpoint for private access to S3. Recommended for EKS clusters"
  type        = bool
  default     = true
}

variable "enable_ecr_endpoints" {
  description = "Enable ECR API and DKR VPC Endpoints. Required for private EKS clusters to pull images"
  type        = bool
  default     = true
}

variable "enable_ssm_endpoint" {
  description = "Enable SSM VPC Endpoint. Required for Session Manager access to private instances"
  type        = bool
  default     = true
}

# VPC Flow Logs Configuration
# -------------------------

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic analysis and security monitoring"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch Logs"
  type        = number
  default     = 7
}

# Additional Security Configuration
# ------------------------------

variable "enable_network_firewall" {
  description = "Enable AWS Network Firewall for additional network security (if required)"
  type        = bool
  default     = false
}

variable "network_firewall_policy" {
  description = "Network Firewall policy configuration (if network firewall is enabled)"
  type        = map(any)
  default     = {}
}

# Route Table Configuration
# -----------------------

variable "custom_route_tables" {
  description = "Additional custom route tables for specific routing requirements"
  type        = map(any)
  default     = {}
}

# VPC Endpoint Security Group Configuration
# --------------------------------------

variable "vpc_endpoint_sg_ingress_rules" {
  description = "Additional ingress rules for VPC endpoint security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# Note: These variables provide extensive customization options for the VPC
# while maintaining secure defaults. The defaults are set to support a
# typical private EKS cluster deployment with necessary VPC endpoints
# and security configurations.
