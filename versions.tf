# Terraform Version Constraint
# --------------------------
# Ensures compatibility with the configuration and prevents use with incompatible versions
terraform {
  required_version = ">= 1.0.0"

  # Required Provider Configurations
  # ------------------------------
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    # Kubernetes Provider
    # Used for managing Kubernetes resources within the EKS cluster
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
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