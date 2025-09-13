variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "wiz"
}

variable "s3_bucket_db_backups_name" {
  description = "S3 Bucket Name for DB Backups"
  type        = string
  default     = "wiz-s3-bucket-db-backups"
}

variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "wiz-eks-cluster"
}

variable "eks_cluster_cidr" {
  description = "The CIDR block of the EKS cluster for MongoDB access control."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
