output "vpc_id" {
  description = "The ID of the VPC."
  value = aws_vpc.this.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway."
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  value       = aws_subnet.private[*].cidr_block
}

output "ec2_instance_sg_id" {
  description = "The ID of the security group attached to the EC2 instance."
  value       = aws_security_group.ec2_instance_sg.id
}

output "alb_sg_id" {
  description = "The ID of the security group attached to the ALB."
  value       = aws_security_group.alb_sg.id
}

output "eks_node_sg_id" {
  description = "The ID of the security group attached to the EKS node."
  value       = aws_security_group.eks_node_sg.id
}