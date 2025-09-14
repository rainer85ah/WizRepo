# Networking
output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID where resources are deployed"
}

output "public_subnets_ids" {
  value       = module.network.public_subnet_ids
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "List of private subnet IDs"
}

output "internet_gateway_id" {
  value       = module.network.internet_gateway_id
  description = "Internet Gateway ID"
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  value       = module.network.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  value       = module.network.private_subnet_cidrs
}

output "ec2_instance_sg_id" {
  description = "The ID of the security group attached to the EC2 instances."
  value       = module.network.ec2_instance_sg_id
}

output "alb_sg_id" {
  description = "The ID of the security group attached to the ALB."
  value       = module.network.alb_sg_id
}

output "eks_node_sg_id" {
  description = "The ID of the security group attached to the EKS node."
  value       = module.network.eks_node_sg_id
}

# EC2
output "ec2_instance_ids" {
  description = "A list of the IDs of the EC2 instances."
  value       = module.ec2.ec2_instance_ids
}

output "ec2_public_ips" {
  description = "A list of the public IP addresses assigned to the EC2 instances."
  value       = module.ec2.ec2_public_ips
}

output "ec2_private_ips" {
  description = "A list of the private IP addresses of the EC2 instances."
  value       = module.ec2.ec2_private_ips
}
