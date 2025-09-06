output "webapp_deployment_name" {
  value       = kubernetes_deployment.webapp.metadata[0].name
  description = "Name of the webapp deployment in Kubernetes."
}

output "webapp_service_name" {
  value       = kubernetes_service.webapp_lb.metadata[0].name
  description = "Name of the LoadBalancer service for the webapp."
}

output "webapp_hpa_name" {
  value       = kubernetes_horizontal_pod_autoscaler.web.metadata[0].name
  description = "Name of the Horizontal Pod Autoscaler for the webapp."
}
