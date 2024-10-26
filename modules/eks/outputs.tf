# EKS Module Outputs
# ================

# Cluster Identification Outputs
# ---------------------------

output "cluster_id" {
  description = "The ID of the EKS cluster. Used for AWS CLI commands and resource references"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "The name of the EKS cluster. Used for kubectl context and resource naming"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster. Used for IAM policies and cross-account access"
  value       = aws_eks_cluster.main.arn
}

# Cluster Access Outputs
# -------------------

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server. Used for kubectl and other API clients"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data for the EKS cluster. Used for client authentication"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

# Security Outputs
# --------------

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster. Used for network security rules"
  value       = aws_security_group.eks_cluster.id
}

# IAM Role Outputs
# --------------

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster. Used for cluster permissions management"
  value       = aws_iam_role.eks_cluster.arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster. Used for policy attachments"
  value       = aws_iam_role.eks_cluster.name
}

output "node_groups_iam_role_arn" {
  description = "IAM role ARN for EKS node groups. Used for node permissions management"
  value       = aws_iam_role.node_groups.arn
}

output "node_groups_iam_role_name" {
  description = "IAM role name for EKS node groups. Used for policy attachments"
  value       = aws_iam_role.node_groups.name
}

# Node Group Outputs
# ---------------

output "system_node_group_id" {
  description = "ID of the EKS system node group. Used for node group management"
  value       = aws_eks_node_group.system.id
}

output "system_node_group_arn" {
  description = "ARN of the EKS system node group. Used for IAM policies"
  value       = aws_eks_node_group.system.arn
}

output "system_node_group_status" {
  description = "Status of the EKS system node group. Used for monitoring deployment status"
  value       = aws_eks_node_group.system.status
}

output "worker_node_group_id" {
  description = "ID of the EKS worker node group. Used for node group management"
  value       = aws_eks_node_group.workers.id
}

output "worker_node_group_arn" {
  description = "ARN of the EKS worker node group. Used for IAM policies"
  value       = aws_eks_node_group.workers.arn
}

output "worker_node_group_status" {
  description = "Status of the EKS worker node group. Used for monitoring deployment status"
  value       = aws_eks_node_group.workers.status
}

# OIDC Provider Outputs
# ------------------

output "cluster_oidc_issuer_url" {
  description = "The URL of the OIDC provider for the cluster. Used for IAM roles for service accounts"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# EBS CSI Driver Outputs
# -------------------

output "ebs_csi_iam_role_arn" {
  description = "ARN of IAM role for EBS CSI driver. Used for persistent volume management"
  value       = aws_iam_role.ebs_csi.arn
}

# KMS Outputs
# ---------

output "kms_key_arn" {
  description = "ARN of KMS key for EKS cluster encryption. Used for encryption configuration"
  value       = aws_kms_key.eks.arn
}

output "kms_key_id" {
  description = "ID of KMS key for EKS cluster encryption. Used for key management"
  value       = aws_kms_key.eks.key_id
}

output "kms_key_alias" {
  description = "Alias of KMS key for EKS cluster encryption. Used for key identification"
  value       = aws_kms_alias.eks.name
}

# Cluster Version Outputs
# --------------------

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster. Used for version compatibility checks"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "Platform version of the EKS cluster. Used for compatibility checks"
  value       = aws_eks_cluster.main.platform_version
}

# Cluster Status Output
# ------------------

output "cluster_status" {
  description = "Status of the EKS cluster. Used for monitoring deployment status"
  value       = aws_eks_cluster.main.status
}

# Kubectl Configuration Output
# ------------------------

output "kubectl_config_command" {
  description = "Command to configure kubectl for cluster access"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_region.current.name}"
}

# Current Region Data Source
# -----------------------
data "aws_region" "current" {}

# Note: These outputs provide comprehensive information about the EKS cluster
# and its components. The descriptions explain both what each output contains
# and how it might be used in practice. This information is crucial for
# managing and interacting with the cluster after deployment.
