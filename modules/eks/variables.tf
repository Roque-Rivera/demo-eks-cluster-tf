# EKS Module Variables
# ==================

# Cluster Configuration Variables
# ----------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster. Used as identifier and prefix for related resources"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster. Should be supported by AWS EKS"
  type        = string
  default     = "1.27"
}

# Network Configuration Variables
# ---------------------------

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created. Must have appropriate networking setup"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where EKS nodes will be launched. Must be in at least two AZs"
  type        = list(string)
}

# Node Group Configuration Variables
# ------------------------------

variable "system_node_group_name" {
  description = "Name of the EKS system node group. Will run critical cluster components"
  type        = string
  default     = "system"
}

variable "worker_node_group_name" {
  description = "Name of the EKS worker node group. Will run application workloads"
  type        = string
  default     = "workers"
}

variable "system_node_instance_type" {
  description = "EC2 instance type for system nodes. Should be appropriate for system workloads"
  type        = string
  default     = "t3.medium"
}

variable "worker_node_instance_type" {
  description = "EC2 instance type for worker nodes. Should be appropriate for application workloads"
  type        = string
  default     = "t3.large"
}

# Node Group Scaling Configuration
# -----------------------------

variable "system_node_desired_size" {
  description = "Desired number of system nodes. Should be enough to run critical components"
  type        = number
  default     = 2
}

variable "system_node_max_size" {
  description = "Maximum number of system nodes. Limits auto-scaling of system nodes"
  type        = number
  default     = 3
}

variable "system_node_min_size" {
  description = "Minimum number of system nodes. Ensures high availability of critical components"
  type        = number
  default     = 1
}

variable "worker_node_desired_size" {
  description = "Desired number of worker nodes. Should handle expected application load"
  type        = number
  default     = 2
}

variable "worker_node_max_size" {
  description = "Maximum number of worker nodes. Limits auto-scaling of application nodes"
  type        = number
  default     = 5
}

variable "worker_node_min_size" {
  description = "Minimum number of worker nodes. Ensures application availability"
  type        = number
  default     = 1
}

# Security Configuration Variables
# ----------------------------

variable "enable_cluster_encryption" {
  description = "Enable envelope encryption for cluster secrets using KMS"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of control plane logging types to enable for enhanced monitoring"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint access for increased security"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint access. Should be false for private clusters"
  type        = bool
  default     = false
}

# Additional Security Group Rules
# ---------------------------

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for the EKS cluster"
  type        = map(any)
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the node groups"
  type        = map(any)
  default     = {}
}

# IRSA Configuration Variables
# -------------------------

variable "enable_irsa" {
  description = "Enable IAM roles for service accounts for fine-grained pod permissions"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver for persistent volume support"
  type        = bool
  default     = true
}

# KMS Configuration Variables
# ------------------------

variable "kms_key_deletion_window" {
  description = "Waiting period before KMS key deletion. Longer periods are more secure"
  type        = number
  default     = 7
}

# IAM Configuration Variables
# ------------------------

variable "node_groups_iam_role_additional_policies" {
  description = "Additional IAM policies to attach to node groups role"
  type        = list(string)
  default     = []
}

# Tagging Variables
# --------------

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

# Note: These variables provide extensive customization options for the EKS cluster
# while maintaining secure defaults. The descriptions explain both what each variable
# controls and considerations for setting appropriate values.
