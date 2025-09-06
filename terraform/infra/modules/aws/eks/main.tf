module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.5"

  name        = var.eks_cluster_name
  kubernetes_version = "1.33"
  endpoint_public_access = true
  endpoint_private_access = true

  vpc_id = var.vpc_id
  subnet_ids = concat(var.public_subnet_ids, var.private_subnets_ids)
  control_plane_subnet_ids = var.private_subnets_ids
  enable_irsa = true

  fargate_profiles = {
    web = {
      selectors = [
        { namespace = "default" }
      ]
      subnet_ids = var.private_subnets_ids
    }
  }

  compute_config = {
    enabled = true
    node_pools = ["general-purpose"]
  }

  tags = {
    Name        = var.eks_cluster_name
    Environment = "dev"
    Terraform   = "true"
  }
}

# Security group for EKS pods (private)
resource "aws_security_group" "eks_pod_sg" {
  name = "${var.eks_cluster_name}-eks-pod-sg-"
  description = "EKS pod security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.eks_cluster_name}-eks-pod-sg"
  }
}

# Allow HTTP traffic from internet
resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.eks_pod_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from all IPs"
}

# Allow pods to talk out to the internet
resource "aws_vpc_security_group_egress_rule" "eks_all_outbound" {
  security_group_id = aws_security_group.eks_pod_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound from pods"
}

data "aws_subnet" "private_subnets" {
  count = length(var.private_subnets_ids)
  id    = var.private_subnets_ids[count.index]
}