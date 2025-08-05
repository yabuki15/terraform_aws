# ---VPC & Subnet---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[each.key]

  tags = {
    Name = "${var.project_name}-private-subnet-${each.key + 1}"
  }
}


# ---IGW & Public Routing---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---Private Routing---
# Find the NLB Network Interfaces in each AZ
data "aws_network_interface" "nlb_eni" {
  for_each = { for idx, s in aws_subnet.public : idx => s.id }

  filter {
    name   = "description"
    values = ["ELB net/${var.project_name}-nlb/*"]
  }
  filter {
    name   = "subnet-id"
    values = [each.value]
  }
  depends_on = [aws_lb_listener.main]
}

# Create a dedicated route table for each private subnet
resource "aws_route_table" "private" {
  for_each = { for idx, s in aws_subnet.private : idx => s.id }
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.nlb_eni[each.key].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${each.key + 1}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}