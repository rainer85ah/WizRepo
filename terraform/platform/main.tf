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

