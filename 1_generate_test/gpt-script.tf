provider "aws" {
      region = "us-west-2"  # Change to your desired region
    }

    resource "aws_eks_cluster" "example" {
      name     = "example-cluster"
      role_arn = aws_iam_role.eks_cluster_role.arn

      vpc_config {
        subnet_ids = aws_subnet.example[*].id
      }

      enabled_cluster_log_types = ["api", "audit"]  # Enable audit logging
    }

    resource "aws_iam_role" "eks_cluster_role" {
      name = "eksClusterRole"

      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "eks.amazonaws.com"
            }
          },
        ]
      })
    }

    resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      role       = aws_iam_role.eks_cluster_role.name
    }

    resource "aws_iam_role_policy_attachment" "eks_service_policy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
      role       = aws_iam_role.eks_cluster_role.name
    }

    resource "aws_vpc" "example" {
      cidr_block = "10.0.0.0/16"
    }

    resource "aws_subnet" "example" {
      count = 2
      vpc_id = aws_vpc.example.id
      cidr_block = cidrsubnet(aws_vpc.example.cidr_block, 8, count.index)
    }

    output "cluster_name" {
      value = aws_eks_cluster.example.name
    }