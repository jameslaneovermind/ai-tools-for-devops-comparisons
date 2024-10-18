# Provider configuration
provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

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

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create a VPC for the EKS cluster (you may want to customize this or use an existing VPC)
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "eks-vpc"
  }
}

# Create subnets for the EKS cluster
resource "aws_subnet" "eks_subnet" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks-subnet-${count.index + 1}"
  }
}

# Get available availability zones
data "aws_availability_zones" "available" {}

# Create the EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }

  # Enable control plane logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Create a CloudWatch log group for EKS logs
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/my-eks-cluster/cluster"
  retention_in_days = 7  # Adjust retention period as needed
}

# Output the cluster endpoint and certificate authority data
output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
