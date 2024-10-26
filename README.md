# Private EKS Cluster with Jump Server

This project provides a Terraform configuration for deploying a fully private Amazon EKS cluster with a secure jump server setup. The infrastructure is designed following AWS best practices for security and scalability.

## Architecture Overview

The infrastructure consists of three main components:

### 1. Virtual Private Cloud (VPC)
- Three-tier architecture with separate subnets for different purposes:
  - Public/Web tier: For load balancers and NAT gateways
  - Private/App tier: For EKS nodes and application workloads
  - Private/DB tier: For databases and data storage
- Deployed across two availability zones in eu-central-1
- NAT Gateways for outbound internet access
- VPC Endpoints for private AWS service access:
  - S3 Gateway Endpoint
  - ECR API and DKR Interface Endpoints
  - SSM Interface Endpoint

### 2. EKS Cluster
- Private EKS cluster with no public endpoint
- Two separate node groups:
  - System node group: For cluster-critical workloads
    - Tainted to prevent application workloads
    - Smaller instance types (t3.medium)
  - Worker node group: For application workloads
    - Larger instance types (t3.large)
    - Auto-scaling enabled
- KMS encryption for secrets
- EBS CSI Driver enabled for persistent storage
- IAM Roles for Service Accounts (IRSA) enabled

### 3. Jump Server
- Private EC2 instance with no public IP
- Accessible only through AWS Systems Manager Session Manager
- Pre-installed tools:
  - AWS CLI v2
  - kubectl
  - helm
  - Common utilities (jq, gettext, etc.)
- Located in the private application subnet
- Security group limited to necessary outbound access

## Prerequisites

1. AWS CLI installed and configured
2. Terraform (version >= 1.0.0)
3. AWS account with appropriate permissions
4. AWS Systems Manager Session Manager plugin for your local machine

## Project Structure
```
.
├── README.md
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Root module variables
├── outputs.tf             # Root module outputs
├── versions.tf            # Provider and version constraints
├── terraform.tfvars       # Variable values
└── modules/
    ├── vpc/              # VPC module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/              # EKS module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2/              # Jump Server module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Deployment Instructions

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Review and modify terraform.tfvars as needed:
   ```hcl
   region       = "eu-central-1"
   project_name = "eks-private"
   # ... other variables
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the deployment plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. After deployment, connect to the jump server:
   ```bash
   # Command will be in the terraform output
   aws ssm start-session --target <jump-server-id> --region eu-central-1
   ```

7. Configure kubectl on the jump server:
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region eu-central-1
   ```

## Security Features

- Private EKS API endpoint only
- No public IP addresses for nodes or jump server
- Session Manager access only (no SSH keys needed)
- Encrypted EBS volumes
- KMS encryption for EKS secrets
- IMDSv2 required on all instances
- Security groups limited to necessary access
- VPC endpoints for private AWS service access

## Monitoring and Maintenance

- EKS control plane logging enabled for:
  - API server
  - Audit
  - Authenticator
  - Controller manager
  - Scheduler
- CloudWatch Container Insights ready
- Node groups support automated updates
- Separate node groups for better workload isolation

## Cost Optimization

- t3 instance types for cost-effective compute
- Autoscaling enabled for worker nodes
- NAT Gateways shared across node groups
- gp3 EBS volumes for better performance/cost ratio

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

Note: Ensure all workloads and data are backed up before destroying the infrastructure.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
