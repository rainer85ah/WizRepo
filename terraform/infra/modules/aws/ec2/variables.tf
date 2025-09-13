variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EC2 Instance Name"
  type        = string
  default     = "ec2"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.medium"
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs to deploy the EC2 instance into."
  type        = list(string)
}

variable "ec2_instance_sg_id" {
  description = "The ID of the security group attached to the EC2 instance."
  type        = string
}