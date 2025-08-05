# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-igw"
  }
}

# AZ情報を取得
data "aws_availability_zones" "available" {
  state = "available"
}

# Subnets (4つ)
resource "aws_subnet" "main" {
  count                   = 4
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  # 2つのAZに交互にサブネットを作成 (0, 1, 0, 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index % 2]
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

# Route Table (1つだけ)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "main-rtb"
  }
}

# 4つのサブネットすべてを同じRoute Tableに紐付け
resource "aws_route_table_association" "main" {
  count          = 4
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.public.id
}