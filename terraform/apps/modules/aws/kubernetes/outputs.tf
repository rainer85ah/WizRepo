# Output the DNS name of the AWS Load Balancer
output "webapp_load_balancer_dns" {
  description = "The DNS name of the AWS Load Balancer for the Nginx service."
  value       = try(
    kubernetes_service.webapp_service.status.0.load_balancer.0.ingress.0.hostname,
    "No name available yet."
  )
}