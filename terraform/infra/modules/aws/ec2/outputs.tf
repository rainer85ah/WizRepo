output "ec2_instance_ids" {
  description = "A list of the IDs of the EC2 instances."
  value       = aws_instance.db_instance[*].id
}

output "ec2_public_ips" {
  description = "A list of the public IP addresses assigned to the EC2 instances."
  value       = aws_instance.db_instance[*].public_ip
}

output "ec2_private_ips" {
  description = "A list of the private IP addresses of the EC2 instances."
  value       = aws_instance.db_instance[*].private_ip
}

output "ec2_instance_profiles" {
  description = "A list of the IAM instance profiles associated with the EC2 instances."
  value       = aws_instance.db_instance[*].iam_instance_profile
}
