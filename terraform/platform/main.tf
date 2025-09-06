terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.68.2"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      name = "wiz-platform-"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the recommended 'tfe_outputs' data source for secure access to remote state outputs.
data "tfe_outputs" "infra" {
  organization = "Valuein"
  workspace    = "wiz-infra-"
}

provider "kubernetes" {
  alias = "eks"

  host                   = data.tfe_outputs.infra.values.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.infra.values.eks_cluster_certificate_authority_data)
  token                  = data.tfe_outputs.infra.values.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = data.tfe_outputs.infra.values.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.tfe_outputs.infra.values.eks_cluster_certificate_authority_data)
    token                  = data.tfe_outputs.infra.values.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}


