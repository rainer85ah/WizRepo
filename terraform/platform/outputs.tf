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

output "cluster_oidc_issuer_url" {
  description = "EKS Cluster OIDC Issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_cidr" {
  description = "EKS Cluster CIDR"
  value       = module.eks.eks_cluster_cidr
}