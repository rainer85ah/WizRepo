terraform {
  required_version = "~> 1.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9.0"
    }
  }

  cloud {
    organization = "Valuein"

    workspaces {
      project = "wiz"
      name    = "wiz-oidc-test"
    }
  }
}

provider "aws" {}

data "aws_caller_identity" "current" {}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "The AWS account ID"
}