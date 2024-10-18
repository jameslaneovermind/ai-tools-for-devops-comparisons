 # Configure AWS credentials and region
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create EKS cluster with audit enabled
resource "aws_eks_cluster" "my_eks_cluster" {
  name = "my-eks-cluster"
  version = "1.23"  # Adjust as needed
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id
    ]
    security_group_ids = [
      aws_security_group.eks_cluster_sg.id
    ]
  }
  logging {
    cluster_logging {
      enabled = true
      types = ["audit"]
    }
  }
  tags = {
    Name = "my-eks-cluster"
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create IAM policy for EKS cluster
resource "aws_iam_policy" "eks_cluster_policy" {
  name = "eks-cluster-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:UpdateCluster",
          "iam:CreateServiceLinkedRole",
          "iam:DeleteServiceLinkedRole",
          "iam:GetServiceLinkedRole",
          "iam:ListServiceLinkedRoles",
          "kms:CreateKey",
          "kms:DeleteKey",
          "kms:DescribeKey",
          "kms:EnableKeyRotation",
          "kms:ListAliases",
          "kms:ListKeys",
          "kms:UpdateKeyDescription",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach IAM policy to EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}

# Create VPC and subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-eks-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-subnet-2"
  }
}

# Create security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name = "eks-cluster-sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}