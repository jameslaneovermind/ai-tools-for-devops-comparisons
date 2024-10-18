provider "aws" {
  region = "us-west-2"  # Change this to your desired region
}

# VPC Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# CloudWatch Log Group for EKS Audit Logs
resource "aws_cloudwatch_log_group" "eks_audit" {
  name              = "/aws/eks/my-cluster/audit"
  retention_in_days = 7
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = ["audit"]
  cloudwatch_log_group_retention_in_days = 7

  # Node Group Configuration
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
    }
  }

  # Enable control plane logging to CloudWatch
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

# IAM Role for CloudWatch Logging
resource "aws_iam_role_policy_attachment" "eks_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEKSClusterPolicy"
  role       = module.eks.cluster_iam_role_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}