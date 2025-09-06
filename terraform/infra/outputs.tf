# Networking
output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID where resources are deployed"
}

output "public_subnets" {
  value       = module.network.public_subnet_ids
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = module.network.private_subnet_ids
  description = "List of private subnet IDs"
}

output "internet_gateway_id" {
  value       = module.network.internet_gateway_id
  description = "Internet Gateway ID"
}

# S3
output "bucket_id" {
  description = "The ID of the S3 bucket."
  value       = module.s3_bucket_db_backups.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.s3_bucket_db_backups.bucket_arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = module.s3_bucket_db_backups.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The S3 static website endpoint URL."
  value       = module.s3_bucket_db_backups.website_endpoint
}

# EC2
output "instance_ids" {
  description = "A list of the IDs of the EC2 instances."
  value       = module.ec2.instance_ids
}

output "public_ips" {
  description = "A list of the public IP addresses assigned to the EC2 instances."
  value       = module.ec2.public_ips
}

output "private_ips" {
  description = "A list of the private IP addresses of the EC2 instances."
  value       = module.ec2.private_ips
}

output "instance_profiles" {
  description = "A list of the IAM instance profiles associated with the EC2 instances."
  value       = module.ec2.instance_profiles
}

output "security_group_id" {
  description = "The ID of the security group attached to the EC2 instances."
  value       = module.ec2.ec2_instance_sg_id
}

# EKS
output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API server endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "EKS Cluster OIDC Provider Arn"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = module.eks.eks_cluster_security_group_id
}

output "eks_private_subnet_cidrs" {
  description = "The CIDR blocks of the private subnets used by the EKS cluster"
  value       = module.eks.eks_private_subnet_cidrs
}
