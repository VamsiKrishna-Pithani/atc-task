
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "eks_subnet_a" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.eks_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
    protocol = "tcp"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_a.id,
      aws_subnet.eks_subnet_b.id
    ]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }
}

resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role       = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]
  desired_size    = 2
  max_size        = 3
  min_size        = 1
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}
