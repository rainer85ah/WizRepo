variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "wiz-eks-cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "Endpoint for the EKS cluster"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "Base64 encoded CA certificate for the EKS cluster"
}

variable "cluster_auth_token" {
  type        = string
  description = "EKS cluster token"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the EKS cluster is deployed"
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "eks_admin_sa_role_arn" {
  type        = string
  description = "ARN of the EKS admin IAM role"
}

variable "eks_admin_sa_role_name" {
  type        = string
  description = "Name of the EKS admin IAM role"
}