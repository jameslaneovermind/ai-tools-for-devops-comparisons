variable "instance_type" {
    default = "t3.medium"
    type = string
}

variable "region" {
    default = "us-west-2"
    type = string
}

variable "cluster_name" {
    default = "example"
    type = string
}

variable "node_count" {
    default = 3
    type = number
}

provider "aws" {
    region = var.region
}

resource "aws_iam_role" "example" {
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Principal = {
              Service = "ec2.amazonaws.com"
            }
            Effect = "Allow"
          }
        ]
      })
    description = "EKS example role"
    name = "eks-example"
}

resource "aws_iam_role_policy_attachment" "example_container" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example_cni" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.example.name
}

resource "aws_cloudwatch_log_group" "example" {
    name = "/aws/eks/${var.cluster_name}/cluster"
    retention_in_days = 7
}

resource "aws_eks_cluster" "example" {
    depends_on = [
        aws_cloudwatch_log_group.example,
    ]
    enabled_cluster_log_types = [
        "api",
        "audit",
    ]
    name = var.cluster_name
}

resource "aws_eks_node_group" "example" {
    cluster_name = aws_eks_cluster.example.name
    instance_types = [
        var.instance_type,
    ]
    node_group_name = "example"
    node_role_arn = aws_iam_role.example.arn
    scaling_config {
        desired_size = var.node_count
        max_size = var.node_count
        min_size = var.node_count
    }
}

resource "aws_iam_role_policy_attachment" "example" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.example.name
}