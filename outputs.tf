# VPC Outputs
# -----------

output "vpc_id" {
  description = "The ID of the VPC. Used for creating resources that need VPC association"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs in the web tier. Used for internet-facing resources"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of private subnet IDs in the application tier. Used for EKS nodes and application resources"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of private subnet IDs in the database tier. Used for database resources"
  value       = module.vpc.private_db_subnet_ids
}

# EKS Cluster Outputs
# ------------------

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS control plane API server. Used for kubectl and other management tools"
  value       = module.eks.cluster_endpoint
  sensitive   = true  # Marked sensitive as it's a security endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster. Used for AWS CLI commands and kubectl context"
  value       = module.eks.cluster_name
}

output "eks_cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster. Used for authentication to the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true  # Marked sensitive as it's a security credential
}

# Jump Server Outputs
# -----------------

output "jump_server_id" {
  description = "ID of the jump server EC2 instance. Used for SSM Session Manager connections"
  value       = module.jump_server.instance_id
}

output "jump_server_ssm_command" {
  description = "AWS Systems Manager Session Manager command to connect to the jump server"
  value       = "aws ssm start-session --target ${module.jump_server.instance_id} --region ${var.region}"
}

# Usage Instructions Output
# -----------------------

output "connection_instructions" {
  description = "Instructions for connecting to the EKS cluster through the jump server"
  value       = <<-EOT
    To connect to your EKS cluster:

    1. Start a session with the jump server:
       ${module.jump_server.ssm_connection_command}

    2. Configure kubectl (already installed on jump server):
       aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}

    3. Test the connection:
       kubectl get nodes

    Note: The jump server has all necessary tools pre-installed:
    - AWS CLI
    - kubectl
    - helm
    - Other common utilities

    The jump server is in a private subnet and can only be accessed via AWS Systems Manager Session Manager.
    EOT
}

# Security Group Outputs
# --------------------

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group. Used for additional security rules if needed"
  value       = module.eks.cluster_security_group_id
}

output "jump_server_security_group_id" {
  description = "ID of the jump server security group. Used for additional security rules if needed"
  value       = module.jump_server.security_group_id
}

# Node Group Outputs
# ----------------

output "system_node_group_id" {
  description = "ID of the system node group. Used for monitoring and management"
  value       = module.eks.system_node_group_id
}

output "worker_node_group_id" {
  description = "ID of the worker node group. Used for monitoring and management"
  value       = module.eks.worker_node_group_id
}
