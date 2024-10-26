# EC2 Jump Server Module
# ====================

# IAM Role for EC2 Instance
# ------------------------
# Role that allows the EC2 instance to use Systems Manager Session Manager
resource "aws_iam_role" "jump_server" {
  name = "${var.project_name}-jump-server-role"

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

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jump-server-role"
    }
  )
}

# Attach SSM Policy to Role
# -----------------------
# Allows EC2 instance to be managed via Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jump_server.name
}

# Create EC2 Instance Profile
# ------------------------
# Associates the IAM role with the EC2 instance
resource "aws_iam_instance_profile" "jump_server" {
  name = "${var.project_name}-jump-server-profile"
  role = aws_iam_role.jump_server.name
}

# Security Group for Jump Server
# ---------------------------
# Controls network access to and from the jump server
resource "aws_security_group" "jump_server" {
  name_prefix = "${var.project_name}-jump-server-"
  description = "Security group for jump server"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jump-server-sg"
    }
  )
}

# Data Source for Latest Amazon Linux 2 AMI
# --------------------------------------
# Gets the latest Amazon Linux 2 AMI for the current region
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Jump Server EC2 Instance
# ----------------------
# The EC2 instance that will serve as the jump server
resource "aws_instance" "jump_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.jump_server.name
  vpc_security_group_ids = [aws_security_group.jump_server.id]

  # Disable public IP as this is a private instance
  associate_public_ip_address = false

  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-jump-server-root"
      }
    )
  }

  # User data script to install required tools
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Update system packages
    yum update -y
    yum install -y jq gettext bash-completion moreutils
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    yum install -y unzip
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
    
    # Install helm
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    
    # Configure kubectl bash completion
    echo 'source <(kubectl completion bash)' >> /home/ec2-user/.bashrc
    echo 'alias k=kubectl' >> /home/ec2-user/.bashrc
    echo 'complete -o default -F __start_kubectl k' >> /home/ec2-user/.bashrc
    
    # Set AWS region
    echo "export AWS_DEFAULT_REGION=${var.region}" >> /home/ec2-user/.bashrc
  EOF
  )

  # Instance metadata options for IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                = "required"  # Require IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jump-server"
    }
  )

  # Prevent replacement when user data changes
  lifecycle {
    ignore_changes = [user_data]
  }
}

# Additional Security Group Rule for EKS Access
# -----------------------------------------
# Allows the jump server to access the EKS API server
resource "aws_security_group_rule" "eks_api" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jump_server.id
  security_group_id        = var.eks_cluster_security_group_id
  description             = "Allow jump server access to EKS API"
}

# Note: This module creates a private EC2 instance that serves as a jump server
# for managing the EKS cluster. The instance is configured with necessary tools
# and permissions, and can only be accessed via AWS Systems Manager Session Manager.
