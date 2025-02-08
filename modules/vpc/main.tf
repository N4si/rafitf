# modules/vpc/main.tf

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw-${terraform.workspace}"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}-${terraform.workspace}"
  }
}

# resource "aws_subnet" "private" {
#   count             = length(var.private_subnets)
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = var.private_subnets[count.index]
#   availability_zone = var.azs[count.index]
#   tags = {
#     Name = "${var.vpc_name}-private-subnet-${count.index + 1}-${terraform.workspace}"
#   }
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt-${terraform.workspace}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.vpc_name}-nat-eip-${terraform.workspace}"
#   }
# }

# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
#   tags = {
#     Name = "${var.vpc_name}-nat-gw-${terraform.workspace}"
#   }
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.this.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.this.id
#   }
#   tags = {
#     Name = "${var.vpc_name}-private-rt-${terraform.workspace}"
#   }
# }

# resource "aws_route_table_association" "private" {
#   count          = length(var.private_subnets)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }