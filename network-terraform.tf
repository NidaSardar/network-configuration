provider "aws" {
  profile = "nidasardar"
  region  = var.region
  
}

data "aws_availability_zones" "available" {}

# Vpc resource
resource "aws_vpc" "myVpc" {
  cidr_block           = var.vpc-cidr-range
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc-name
  }
}

# Internet gateway for the public subnets
resource "aws_internet_gateway" "myInternetGateway" {
  vpc_id = aws_vpc.myVpc.id
  tags = {
    Name = var.IGW-name
  }
}

# Subnet (public)
resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.20.${10+count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public-subnet-name
  }
}

# Subnet (private)
resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.20.${20+count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = var.private-subnet-name
  }
}

# Routing table for public subnets
resource "aws_route_table" "rtblPublic" {
  vpc_id = aws_vpc.myVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway.id
  }
  tags = {
    Name = var.public-RT
  }
}

resource "aws_route_table_association" "route" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.rtblPublic.id
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 1)
  depends_on    = [aws_internet_gateway.myInternetGateway]
}

# Routing table for private subnets
resource "aws_route_table" "rtblPrivate" {
  vpc_id = aws_vpc.myVpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = var.private-RT
  }
}

resource "aws_route_table_association" "private_route" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.rtblPrivate.id
}