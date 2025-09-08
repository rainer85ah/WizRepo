output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster certificate_authority_data"
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "EKS Cluster OIDC Provider Arn"
  value = module.eks.oidc_provider_arn
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

# output "eks_pod_sg_id" {
#   value = aws_security_group.eks_pod_sg.id
# }

output "eks_cluster_cidr" {
  value = module.eks.cluster_service_cidr
}

output "eks_admin_sa_role_arn" {
  description = "The ARN of the IAM role with admin access for the EKS service account."
  value       = aws_iam_role.eks_admin_sa_role.arn
}

output "eks_admin_sa_role_name" {
  description = "The name of the IAM role with admin access for the EKS service account."
  value       = aws_iam_role.eks_admin_sa_role.name
}