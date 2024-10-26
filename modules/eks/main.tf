# EKS Module Main Configuration
# ===========================

# EKS Cluster IAM Role
# -------------------
# IAM role that the EKS cluster service will assume to create AWS resources
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  # Trust policy allowing EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required policies to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Cluster
# ----------
# The main EKS cluster resource
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  # VPC configuration for the cluster
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true                          # Enable private API server endpoint
    endpoint_public_access  = false                         # Disable public API server endpoint
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  # Enable control plane logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Enable envelope encryption of Kubernetes secrets
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )

  # Ensure IAM role is created before creating the cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# KMS Key for EKS
# --------------
# Custom KMS key for encrypting Kubernetes secrets
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster ${var.cluster_name} secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true  # Enable automatic key rotation for security

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-key"
    }
  )
}

# KMS Key Alias
resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}

# EKS Cluster Security Group
# ------------------------
# Security group controlling network access to the EKS cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.cluster_name}-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-sg"
    }
  )
}

# Allow all outbound traffic from the cluster
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
}

# Node Groups IAM Role
# ------------------
# IAM role that the EKS node groups will use
resource "aws_iam_role" "node_groups" {
  name = "${var.cluster_name}-node-role"

  # Trust policy allowing EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required policies to the node groups role
resource "aws_iam_role_policy_attachment" "node_groups_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",         # Required for nodes to join the cluster
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",             # Required for VPC CNI plugin
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # Required to pull container images
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"       # Required for SSM access
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_groups.name
}

# System Node Group
# ---------------
# Node group for system workloads (monitoring, logging, etc.)
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.system_node_group_name
  node_role_arn   = aws_iam_role.node_groups.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.system_node_desired_size
    max_size     = var.system_node_max_size
    min_size     = var.system_node_min_size
  }

  instance_types = [var.system_node_instance_type]

  # Taint system nodes to prevent application workloads from scheduling
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  labels = {
    role = "system"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-system-node-group"
    }
  )

  # Ensure IAM role policies are attached before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.node_groups_policies
  ]
}

# Worker Node Group
# ---------------
# Node group for application workloads
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.worker_node_group_name
  node_role_arn   = aws_iam_role.node_groups.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.worker_node_desired_size
    max_size     = var.worker_node_max_size
    min_size     = var.worker_node_min_size
  }

  instance_types = [var.worker_node_instance_type]

  labels = {
    role = "worker"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-worker-node-group"
    }
  )

  # Ensure IAM role policies are attached before creating node group
  depends_on = [
    aws_iam_role_policy_attachment.node_groups_policies
  ]
}

# IRSA for EBS CSI Driver
# ---------------------
# IAM role for service account to enable EBS CSI driver
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-role"

  # Trust policy allowing EKS service account to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attach EBS CSI policy to the IRSA role
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

# Data Sources
# -----------
# Get current AWS account ID for IRSA configuration
data "aws_caller_identity" "current" {}
