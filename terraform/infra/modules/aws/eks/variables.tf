variable "eks_cluster_name" {
    description = "EKS Cluster Name"
    type        = string
    default     = "wiz-eks-cluster"
}

variable "vpc_id" {
  description = "VPC ID where resources are deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}
