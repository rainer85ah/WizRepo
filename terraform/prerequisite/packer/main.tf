# --- VPC ---
resource "aws_vpc" "packer-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "packer-vpc" }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "packer-igw" {
  vpc_id = aws_vpc.packer-vpc.id
  tags   = { Name = "packer-igw" }
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.packer-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "packer-public-subnet" }
}

# --- Route Table ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.packer-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.packer-igw.id
  }
  tags = { Name = "packer-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
