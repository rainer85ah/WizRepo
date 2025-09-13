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
}

provider "hcp" {}

provider "aws" {
  region = var.aws_region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Terraform IAM Role (For Terraform to manage EKS)
resource "aws_iam_role" "terraform_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/app.terraform.io"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "app.terraform.io:aud" = "aws.workload.identity"
          }
          StringLike = {
            "app.terraform.io:sub" = "organization:Valuein:project:wiz:workspace:*:run_phase:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = var.role_name
  }
}

# Attach AdministratorAccess (for testing/dev purposes)
resource "aws_iam_role_policy_attachment" "attach_admin" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}