# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn  # Keep ARN here (correct usage)

  vpc_config {
    subnet_ids              = var.public_subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Attach EKS Cluster Policy to IAM Role (Cluster Role)
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  # Extract role name from the cluster role ARN
  role       = split("/", var.eks_cluster_role_arn)[1]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Worker Nodes (Self-Managed)
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.worker_node_role_arn  # Keep ARN here (correct usage)
  subnet_ids      = var.public_subnet_ids
  instance_types   = ["t2.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # remote_access {
  #   ec2_ssh_key = "your-key-pair" # Update with your key pair
  # }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only
  ]
}

# Attach Worker Node Policies to IAM Role (Worker Node Role)
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  # Extract role name from the worker node role ARN
  role       = split("/", var.worker_node_role_arn)[1]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  # Extract role name from the worker node role ARN
  role       = split("/", var.worker_node_role_arn)[1]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  # Extract role name from the worker node role ARN
  role       = split("/", var.worker_node_role_arn)[1]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}