# Configure the AWS Provider
# This is the main provider configuration for AWS resources
provider "aws" {
  region = var.region
}

# VPC Module
# This module creates the networking infrastructure including VPC, subnets, NAT gateways, and VPC endpoints
module "vpc" {
  source = "./modules/vpc"

  # Basic VPC configuration
  region               = var.region
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  
  # Network configuration
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs          # Web tier subnets
  private_app_subnet_cidrs = var.private_app_subnet_cidrs # Application tier subnets
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs  # Database tier subnets
}

# EKS Module
# This module creates the EKS cluster, node groups, and associated resources
module "eks" {
  source = "./modules/eks"

  # Basic cluster configuration
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_app_subnet_ids # Using app tier subnets for EKS nodes
  
  # Cluster naming
  cluster_name         = var.cluster_name
  node_group_name      = var.node_group_name
  system_node_group_name = var.system_node_group_name
}

# EC2 Jump Server Module
# This module creates a private EC2 instance that serves as a jump server for cluster management
module "jump_server" {
  source = "./modules/ec2"

  # Basic instance configuration
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_app_subnet_ids[0] # Place jump server in first app subnet
  instance_type        = var.jump_server_instance_type
  key_name             = var.key_name
}
