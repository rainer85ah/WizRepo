# IAM for EC2

# Create a highly permissive IAM policy
resource "aws_iam_policy" "highly_privileged_policy" {
  name        = "HighlyPrivilegedEC2Policy"
  description = "An overly permissive IAM policy for the EC2 instance (for demonstration)."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "privileged_ec2_role" {
  name               = "PrivilegedEC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the overly permissive policy to the role
resource "aws_iam_role_policy_attachment" "attach_privileged_policy" {
  role       = aws_iam_role.privileged_ec2_role.name
  policy_arn = aws_iam_policy.highly_privileged_policy.arn
}

# Create an instance profile to associate the role with the EC2 instance
resource "aws_iam_instance_profile" "privileged_instance_profile" {
  name = "PrivilegedEC2InstanceProfile"
  role = aws_iam_role.privileged_ec2_role.name
}

# Security group for the EC2 instance (public)
resource "aws_security_group" "ec2_instance_sg" {
  name = "${var.name}-ec2-instance-sg"
  description = "EC2 instance security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-ec2-instance-sg"
  }
}

# Allow MongoDB traffic from all EKS private subnets
resource "aws_vpc_security_group_ingress_rule" "ec2_mongo" {
  count             = length(var.eks_private_subnet_cidrs)
  security_group_id = aws_security_group.ec2_instance_sg.id
  from_port         = 27017
  to_port           = 27017
  ip_protocol       = "tcp"
  cidr_ipv4         = var.eks_private_subnet_cidrs[count.index]
  description       = "Allow MongoDB traffic from EKS subnet ${var.eks_private_subnet_cidrs[count.index]}"
}

# Allow SSH from internet
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from all IPs"
}

# Allow EC2 outbound to anywhere
resource "aws_vpc_security_group_egress_rule" "ec2_all_outbound" {
  security_group_id = aws_security_group.ec2_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound"
}

data "hcp_packer_version" "mongo_base" {
  bucket_name  = "mongodb-ami"
  channel_name = "latest"
}

data "hcp_packer_artifact" "mongo_ami" {
  bucket_name         = data.hcp_packer_version.mongo_base.bucket_name
  version_fingerprint = data.hcp_packer_version.mongo_base.fingerprint
  platform            = "aws"
  region              = var.aws_region
}

# Define an EC2 instance with MongoDB in each public subnet
resource "aws_instance" "db_instance" {
  count                       = length(var.public_subnet_ids)
  ami                         = data.hcp_packer_artifact.mongo_ami.external_identifier
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids[count.index]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.privileged_instance_profile.name
  vpc_security_group_ids      = [ aws_security_group.ec2_instance_sg.id ]

  tags = {
    Name = "${var.name}-mongodb-${count.index}"
  }

  user_data = <<EOF
    #!/bin/bash
    echo "export S3_BUCKET_NAME=${var.s3_bucket_name}" >> /etc/profile.d/custom_env.sh
    chmod +x /etc/profile.d/custom_env.sh
    EOF
}
