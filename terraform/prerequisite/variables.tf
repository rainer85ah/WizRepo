variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_db_backups_name" {
  description = "S3 Bucket Name for DB Backups"
  type        = string
  default     = "wiz-s3-bucket-db-backups"
}
