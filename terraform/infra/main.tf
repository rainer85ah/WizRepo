terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13.0"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      project = "wiz"
      name    = "wiz-infra-dev"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source       = "./modules/aws/network"
  prefix_name  = "${var.project_name}-network"
  cluster_name = var.eks_cluster_name
}

module "ec2" {
  source             = "./modules/aws/ec2"
  name               = "${var.project_name}-ec2"
  aws_region         = var.aws_region
  public_subnet_ids  = module.network.public_subnet_ids
  ec2_instance_sg_id = module.network.ec2_instance_sg_id
}
