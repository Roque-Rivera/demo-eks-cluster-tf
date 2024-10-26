# General Configuration Variables
# -----------------------------

variable "region" {
  description = "AWS region where resources will be created. Default is eu-central-1 (Frankfurt)"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project. Used as a prefix for resource naming to ensure uniqueness"
  type        = string
  default     = "eks-private"
}

# VPC Configuration Variables
# -------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC. This should be a /16 network to provide enough IP addresses"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones in the region for high availability. Using 2 AZs as per requirement"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public (web tier) subnets. One per AZ, each should be a /20 network"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application tier subnets. One per AZ, each should be a /20 network"
  type        = list(string)
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database tier subnets. One per AZ, each should be a /20 network"
  type        = list(string)
  default     = ["10.0.64.0/20", "10.0.80.0/20"]
}

# EKS Cluster Configuration Variables
# --------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster. This will be used to name various associated resources"
  type        = string
  default     = "eks-private-cluster"
}

variable "node_group_name" {
  description = "Name of the worker node group. These nodes will run application workloads"
  type        = string
  default     = "worker-node-group"
}

variable "system_node_group_name" {
  description = "Name of the system node group. These nodes will run cluster-critical workloads"
  type        = string
  default     = "system-node-group"
}

# Node Group Configuration Variables
# -------------------------------

variable "worker_node_instance_type" {
  description = "EC2 instance type for worker nodes. Should be powerful enough for application workloads"
  type        = string
  default     = "t3.medium"
}

variable "system_node_instance_type" {
  description = "EC2 instance type for system nodes. Can be smaller as they run fewer workloads"
  type        = string
  default     = "t3.small"
}

variable "worker_node_desired_size" {
  description = "Desired number of worker nodes. This is the target size for the node group"
  type        = number
  default     = 2
}

variable "worker_node_max_size" {
  description = "Maximum number of worker nodes. Autoscaling will not exceed this number"
  type        = number
  default     = 4
}

variable "worker_node_min_size" {
  description = "Minimum number of worker nodes. Autoscaling will maintain at least this many nodes"
  type        = number
  default     = 1
}

variable "system_node_desired_size" {
  description = "Desired number of system nodes. Usually matches min_size for stability"
  type        = number
  default     = 2
}

variable "system_node_max_size" {
  description = "Maximum number of system nodes. Usually close to desired_size as system workloads are stable"
  type        = number
  default     = 2
}

variable "system_node_min_size" {
  description = "Minimum number of system nodes. Should be at least 1 for critical workloads"
  type        = number
  default     = 1
}

# Jump Server Configuration Variables
# -------------------------------

variable "jump_server_instance_type" {
  description = "EC2 instance type for the jump server. t3.micro is sufficient for basic management tasks"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for the jump server. Not required as we use SSM for access"
  type        = string
  default     = null
}

# Tagging Variables
# ---------------

variable "tags" {
  description = "Map of tags to apply to all resources for organization and billing purposes"
  type        = map(string)
  default     = {
    Environment = "production"
    Terraform   = "true"
  }
}
