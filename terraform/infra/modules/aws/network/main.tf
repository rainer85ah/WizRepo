# Lookup AZs if not provided
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = (
    length(var.azs) > 0
    ? var.azs
    : slice(data.aws_availability_zones.available.names, 0, var.maximum_azs)
  )
  az_count = length(local.azs)
}

# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prefix_name}-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  count                   = local.az_count
  availability_zone       = local.azs[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"                     = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prefix_name}-public-rt"
  }
}

# Create Public Route Table Association
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create Public Subnet Associations
resource "aws_route_table_association" "public_assoc" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Private Subnets
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  count             = local.az_count
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.prefix_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Create NAT EIP
resource "aws_eip" "nat" {
  count = local.az_count
  domain = "vpc"

  tags = {
    Name = "${var.prefix_name}-nat-eip-${count.index + 1}"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  count         = local.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.prefix_name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Private route tables (one per AZ)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  count = local.az_count

  tags = {
    Name = "${var.prefix_name}-private-rt-${count.index + 1}"
  }
}

# Create Private Route Table Association
resource "aws_route" "private_nat_access" {
  count          = local.az_count
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}

# Create Private Subnet Associations
resource "aws_route_table_association" "private_assoc" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
