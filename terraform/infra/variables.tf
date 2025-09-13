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

variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "wiz-eks-cluster"
}
