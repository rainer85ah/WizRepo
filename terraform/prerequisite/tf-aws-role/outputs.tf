output "terraform_role_arn" {
  description = "ARN of the bootstrap role that HCP agents will assume"
  value       = aws_iam_role.terraform_role.arn
}
