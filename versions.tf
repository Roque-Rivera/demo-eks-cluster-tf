# Terraform Version Constraint
# --------------------------
# Ensures compatibility with the configuration and prevents use with incompatible versions
terraform {
  required_version = ">= 1.0.0"

  # Required Provider Configurations
  # ------------------------------
  required_providers {
    # AWS Provider
    # Used for creating all AWS infrastructure resources
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"  # Minimum version required for EKS features
    }

    # Kubernetes Provider
    # Used for managing Kubernetes resources within the EKS cluster
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"  # Version with stable EKS support
    }

    # TLS Provider
    # Used for handling TLS certificates and keys
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

# AWS Provider Configuration
# ------------------------
# Main provider configuration for AWS resources
provider "aws" {
  region = var.region

  # Apply default tags to all resources created by AWS provider
  default_tags {
    tags = var.tags
  }
}

# Kubernetes Provider Configuration
# ------------------------------
# Configuration for managing Kubernetes resources within the EKS cluster
provider "kubernetes" {
  # Use EKS cluster endpoint for API server communication
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Use AWS CLI for authentication to the EKS cluster
  # This ensures proper IAM authentication is used
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # Arguments to get authentication token from AWS
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.region
    ]
  }
}

# Notes:
# -----
# 1. The AWS provider version >= 5.0.0 is required for the latest EKS features
# 2. The Kubernetes provider is configured to use AWS EKS authentication
# 3. TLS provider is included for potential certificate handling needs
# 4. Default tags are applied to all AWS resources for better resource management
# 5. The Kubernetes provider configuration depends on the EKS module outputs
