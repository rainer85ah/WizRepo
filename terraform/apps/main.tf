terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
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
      name    = "wiz-apps-dev"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "kubernetes" {
  source = "./modules/aws/kubernetes"
}
