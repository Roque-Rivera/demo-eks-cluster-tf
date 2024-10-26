# EC2 Jump Server Module Outputs
# ===========================

# Instance Identification Outputs
# ---------------------------

output "instance_id" {
  description = "ID of the EC2 instance. Used for AWS CLI commands and resource references"
  value       = aws_instance.jump_server.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance. Used for IAM policies and resource references"
  value       = aws_instance.jump_server.arn
}

# Network Configuration Outputs
# -------------------------

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance. Used for internal network communication"
  value       = aws_instance.jump_server.private_ip
}

output "subnet_id" {
  description = "ID of the subnet where the instance is deployed. Used for network troubleshooting"
  value       = aws_instance.jump_server.subnet_id
}

# Security Group Outputs
# -------------------

output "security_group_id" {
  description = "ID of the security group attached to the jump server. Used for security rule management"
  value       = aws_security_group.jump_server.id
}

output "security_group_arn" {
  description = "ARN of the security group attached to the jump server. Used for IAM policies"
  value       = aws_security_group.jump_server.arn
}

# IAM Configuration Outputs
# ----------------------

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the jump server. Used for permission management"
  value       = aws_iam_role.jump_server.arn
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the jump server. Used for policy attachments"
  value       = aws_iam_role.jump_server.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile. Used for IAM role association"
  value       = aws_iam_instance_profile.jump_server.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile. Used for EC2 instance configuration"
  value       = aws_iam_instance_profile.jump_server.name
}

# Connection Information Outputs
# --------------------------

output "ssm_connection_command" {
  description = "AWS Systems Manager Session Manager connection command for the jump server"
  value       = "aws ssm start-session --target ${aws_instance.jump_server.id} --region ${var.region}"
}

# Instance Configuration Outputs
# --------------------------

output "ami_id" {
  description = "ID of the AMI used for the instance. Used for instance configuration tracking"
  value       = aws_instance.jump_server.ami
}

output "root_volume_id" {
  description = "ID of the root volume. Used for volume management and snapshots"
  value       = aws_instance.jump_server.root_block_device[0].volume_id
}

# Tagging Outputs
# ------------

output "tags" {
  description = "Tags applied to the instance. Used for resource organization and tracking"
  value       = aws_instance.jump_server.tags
}

# Usage Instructions Output
# ---------------------

output "connection_instructions" {
  description = "Instructions for connecting to and using the jump server"
  value       = <<-EOT
    To connect to the jump server:

    1. Ensure you have AWS CLI installed and configured
    2. Run the following command:
       ${local.ssm_connection_command}

    Available tools on the jump server:
    - AWS CLI v2
    - kubectl
    - helm
    - Common utilities (jq, gettext, etc.)

    To connect to the EKS cluster:
    1. Connect to the jump server using the command above
    2. Run: aws eks update-kubeconfig --name <cluster-name> --region ${var.region}
    3. Verify connection: kubectl get nodes

    Note: This jump server is in a private subnet and can only be accessed via AWS Systems Manager Session Manager.
    EOT
}

# Additional Configuration Outputs
# ----------------------------

output "instance_state" {
  description = "Current state of the EC2 instance. Used for monitoring instance status"
  value       = aws_instance.jump_server.instance_state
}

output "ebs_optimized" {
  description = "Whether the instance is EBS optimized. Used for performance monitoring"
  value       = aws_instance.jump_server.ebs_optimized
}

output "metadata_options" {
  description = "Metadata options configured for the instance. Used for security verification"
  value       = aws_instance.jump_server.metadata_options
}

# Local Variables
# ------------

locals {
  ssm_connection_command = "aws ssm start-session --target ${aws_instance.jump_server.id} --region ${var.region}"
}

# Note: These outputs provide comprehensive information about the jump server
# and its associated resources. The descriptions explain both what each output
# contains and how it might be used in practice. This information is crucial
# for managing and accessing the jump server after deployment.
