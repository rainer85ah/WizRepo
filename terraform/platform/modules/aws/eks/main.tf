module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  region  = var.aws_region

  kubernetes_version = "1.33"
  vpc_id             = var.vpc_id
  name               = var.cluster_name
  subnet_ids         = var.private_subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  endpoint_public_access  = true
  endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    webapp_nodes = {
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 2
      desired_size = 2
      node_labels = {
        "app" = "webapp"
      }
    }
  }

  tags = {
    Name        = var.cluster_name
    Environment = "dev"
    Terraform   = "true"
  }
}
