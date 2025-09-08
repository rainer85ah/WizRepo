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
      name    = "wiz-infra-"
    }
  }
}

provider "hcp" {}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/aws/network"
  name   = "${var.project_name}-network"
}

module "s3_bucket_db_backups" {
  source = "./modules/aws/s3"
  name   = var.s3_bucket_db_backups_name
}

module "eks" {
  source              = "./modules/aws/eks"
  eks_cluster_name    = "${var.project_name}-eks"
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnets_ids = module.network.private_subnet_ids
}

module "ec2" {
  source                   = "./modules/aws/ec2"
  name                     = "${var.project_name}-ec2-mongodb"
  public_subnet_ids        = module.network.public_subnet_ids
  vpc_id                   = module.network.vpc_id
  aws_region               = var.aws_region
  s3_bucket_name           = module.s3_bucket_db_backups.bucket_id
  eks_private_subnet_cidrs = module.network.private_subnet_cidrs
}
