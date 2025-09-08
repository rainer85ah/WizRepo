output "webapp_deployment_name" {
  description = "Name of the webapp deployment"
  value       = module.kubernetes.webapp_deployment_name
}

output "webapp_service_dns" {
  value       = module.kubernetes.webapp_service_dns
  description = "DNS name of the ALB exposing the webapp"
}
