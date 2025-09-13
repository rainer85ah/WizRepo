output "load_balancer_hostname" {
  description = "Public DNS of the ALB for the Nginx Ingress"
  value       = module.kubernetes.webapp_load_balancer_dns
}