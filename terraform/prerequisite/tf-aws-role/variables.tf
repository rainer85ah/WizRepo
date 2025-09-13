variable "aws_region" {
  type        = string
  description = "AWS region where the role will be created"
  default     = "us-east-1"
}

variable "role_name" {
  type        = string
  default     = "terraform-aws-role"
  description = "Name of the role to create for HCP Terraform agent"
}