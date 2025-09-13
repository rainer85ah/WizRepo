output "vpc_id" {
  value = aws_vpc.packer-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "ubuntu_ami" {
  value = data.aws_ami.ubuntu.id
}