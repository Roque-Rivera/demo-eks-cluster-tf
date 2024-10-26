# EC2 Jump Server Module Variables
# =============================

# Basic Configuration Variables
# --------------------------

variable "project_name" {
  description = "Name of the project. Used as a prefix for resource naming to ensure uniqueness"
  type        = string
}

variable "region" {
  description = "AWS region where the jump server will be created. Used for AWS CLI configuration"
  type        = string
}

# Network Configuration Variables
# ---------------------------

variable "vpc_id" {
  description = "ID of the VPC where the jump server will be created. Must have appropriate VPC endpoints"
  type        = string
}

variable "subnet_id" {
  description = "ID of the private subnet where the jump server will be created. Must have SSM endpoint access"
  type        = string
}

# Instance Configuration Variables
# ----------------------------

variable "instance_type" {
  description = "EC2 instance type for the jump server. t3.micro is sufficient for basic management tasks"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB. Should be sufficient for OS and tools"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume (gp3 recommended for better performance)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Enable encryption for the root volume using default KMS key"
  type        = bool
  default     = true
}

# Security Configuration Variables
# ----------------------------

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster. Required for allowing jump server access"
  type        = string
}

# Monitoring Configuration Variables
# ------------------------------

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for the instance"
  type        = bool
  default     = false
}

# Additional Security Group Rules
# ---------------------------

variable "additional_security_group_rules" {
  description = "Additional security group rules for the jump server"
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# Instance Advanced Configuration
# ---------------------------

variable "ebs_optimized" {
  description = "Enable EBS optimization for better volume performance"
  type        = bool
  default     = true
}

variable "metadata_options" {
  description = "Metadata options for the EC2 instance (IMDSv2 configuration)"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

# IAM Configuration Variables
# ------------------------

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

# Instance Protection Variables
# -------------------------

variable "enable_termination_protection" {
  description = "Enable termination protection for the instance"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance (stop or terminate)"
  type        = string
  default     = "stop"
}

# Performance Configuration Variables
# -------------------------------

variable "cpu_credits" {
  description = "CPU credit option for burstable instances (standard or unlimited)"
  type        = string
  default     = "standard"
}

# Tagging Variables
# --------------

variable "tags" {
  description = "Map of tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

# Note: These variables provide extensive customization options for the jump server
# while maintaining secure defaults. The descriptions explain both what each variable
# controls and considerations for setting appropriate values.
