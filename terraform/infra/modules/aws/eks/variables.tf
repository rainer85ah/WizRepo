variable "cluster_name" {
    description = "EKS Cluster Name"
    type        = string
}

variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where resources are deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}
