data "aws_caller_identity" "current" {}

# AWS Account ID
output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "The AWS account ID"
}

# S3
output "s3_bucket_id" {
  description = "The ID of the S3 bucket."
  value       = module.s3_bucket_db_backups.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.s3_bucket_db_backups.s3_bucket_arn
}

output "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = module.s3_bucket_db_backups.s3_bucket_regional_domain_name
}

# Packer
output "packer_vpc_id" {
  value = module.mongodb-ami.vpc_id
}

output "packer_public_subnet_id" {
  value = module.mongodb-ami.public_subnet_id
}

output "packer_ubuntu_ami" {
  value = module.mongodb-ami.ubuntu_ami
}