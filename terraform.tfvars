# General
region       = "eu-central-1"
project_name = "demo-eks-private"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = [
  "eu-central-1a",
  "eu-central-1b"
]
public_subnet_cidrs = [
  "10.0.0.0/20",
  "10.0.16.0/20"
]
private_app_subnet_cidrs = [
  "10.0.32.0/20",
  "10.0.48.0/20"
]
private_db_subnet_cidrs = [
  "10.0.64.0/20",
  "10.0.80.0/20"
]

# EKS Configuration
cluster_name             = "eks-private-cluster"
kubernetes_version       = "1.31"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false

# EKS Node Groups
system_node_group_name     = "system"
worker_node_group_name     = "workers"
system_node_instance_type  = "t3.medium"
worker_node_instance_type  = "t3.large"

system_node_desired_size = 2
system_node_max_size     = 3
system_node_min_size     = 1

worker_node_desired_size = 2
worker_node_max_size     = 5
worker_node_min_size     = 1

# Jump Server Configuration
jump_server_instance_type = "t3.micro"
root_volume_size         = 30
root_volume_type         = "gp3"
enable_detailed_monitoring = false

# Tags
tags = {
  Environment = "production"
  Terraform   = "true"
  Project     = "eks-private"
}

# Security
enable_cluster_encryption = true
enable_irsa              = true
enable_ebs_csi_driver    = true

# Monitoring and Logging
cluster_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]
