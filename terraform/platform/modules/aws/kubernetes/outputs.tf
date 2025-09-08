output "webapp_deployment_name" {
  description = "Name of the webapp deployment"
  value       = kubernetes_deployment.webapp.metadata[0].name
}

output "webapp_service_dns" {
  value       = try(kubernetes_service.webapp_lb.status[0].load_balancer[0].ingress[0].hostname, "ALB not created yet.")
  description = "DNS name of the ALB exposing the webapp"
}
