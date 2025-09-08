variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EC2 Instance Name"
  type        = string
  default     = "ec2"
}

variable "vpc_id" {
  description = "The VPC ID to deploy the EC2 instance into."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs to deploy the EC2 instance into."
  type        = list(string)
}

variable "s3_bucket_name" {
  description = "The S3 bucket name to store MongoDB backups."
  type        = string
}

variable "eks_private_subnet_cidrs" {
  description = "The CIDR blocks of the private subnets used by the EKS cluster"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
