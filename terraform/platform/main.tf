terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.109.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.68.2"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      project = "wiz"
      name    = "wiz-platform-dev"
    }
  }
}

provider "hcp" {}

provider "aws" {
  region = var.aws_region
}

# Get EKS cluster info from TFE
data "tfe_outputs" "infra" {
  organization = "Valuein"
  workspace    = "wiz-infra-dev"
}

module "eks" {
  source             = "./modules/aws/eks"
  cluster_name       = var.eks_cluster_name
  aws_region         = var.aws_region
  vpc_id             = data.tfe_outputs.infra.values.vpc_id
  private_subnet_ids = data.tfe_outputs.infra.values.private_subnet_ids
}
