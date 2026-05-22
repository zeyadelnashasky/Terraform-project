# create VPC with 2 public and 2 private subnets, an Internet Gateway, and a NAT Gateway
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

# Create internet gateway and attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" } 
}

# Create 2 Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]  # Ensure public subnets are in different AZs
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-public-subnet-${count.index}" }
}

# Create 2 Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]    # Ensure private subnets are in the same AZs as public subnets
  tags              = { Name = "${var.project_name}-private-subnet-${count.index}" }
}

# Data source to get AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]                # Ensure EIP is created after Internet Gateway to avoid dependency issues
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project_name}-nat-gw" }
  depends_on = [aws_internet_gateway.igw]                 # Ensure NAT Gateway is created after Internet Gateway to avoid dependency issues
}

# Route Tables for Public 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

# Route Tables for Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.project_name}-private-rt" }
}

# Associate Public Route Tables with Subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public.id
}

# Associate Private Route Tables with Subnets
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id 
  route_table_id = aws_route_table.private.id
}