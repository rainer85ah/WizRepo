terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.68.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      project = "wiz"
      name    = "wiz-platform-"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "tfe_outputs" "infra" {
  organization = "Valuein"
  workspace    = "wiz-infra-"
}

data "aws_eks_cluster_auth" "this" {
  name = data.tfe_outputs.infra.values.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.tfe_outputs.infra.values.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.infra.values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.tfe_outputs.infra.values.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.tfe_outputs.infra.values.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "kubernetes" {
  source                             = "./modules/aws/kubernetes"
  aws_region                         = var.aws_region
  vpc_id                             = data.tfe_outputs.infra.values.vpc_id
  cluster_auth_token                 = data.aws_eks_cluster_auth.this.token
  cluster_name                       = data.tfe_outputs.infra.values.eks_cluster_name
  cluster_endpoint                   = data.tfe_outputs.infra.values.eks_cluster_endpoint
  cluster_certificate_authority_data = data.tfe_outputs.infra.values.cluster_certificate_authority_data
  eks_admin_sa_role_arn              = data.tfe_outputs.infra.values.eks_admin_sa_role_arn
  eks_admin_sa_role_name             = data.tfe_outputs.infra.values.eks_admin_sa_role_name
}
