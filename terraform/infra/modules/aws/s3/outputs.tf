output "bucket_id" {
  description = "The ID of the S3 bucket."
  value       = aws_s3_bucket.db_backups_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.db_backups_bucket.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = aws_s3_bucket.db_backups_bucket.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The S3 static website endpoint URL."
  value       = aws_s3_bucket_website_configuration.db_backups_website.website_endpoint
}