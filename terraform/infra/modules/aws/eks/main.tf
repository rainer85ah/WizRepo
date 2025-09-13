module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  region  = var.aws_region

  kubernetes_version = "1.33"
  vpc_id             = var.vpc_id
  name               = var.cluster_name
  subnet_ids         = var.private_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  addons = {
    vpc-cni                = { before_compute = true }
    kube-proxy             = { before_compute = true }
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
  }

  tags = {
    Name        = var.cluster_name
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_caller_identity" "this" {}

# Terraform resource for the access policy association
resource "aws_eks_access_policy_association" "developer_admin" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/odl_user_1851004"

  # The AmazonEKSClusterAdminPolicy grants the most permissive access
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
}
