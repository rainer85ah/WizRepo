terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.109.0"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      project = "wiz"
      name    = "wiz-prereq-dev"
    }
  }
}

provider "hcp" {}

provider "aws" {
  region = var.aws_region
}

module "s3_bucket_db_backups" {
  source = "./s3_bucket"
  name   = var.s3_bucket_db_backups_name
}

module "mongodb-ami" {
  source = "./packer"
}
