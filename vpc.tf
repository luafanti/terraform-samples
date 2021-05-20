# ---------------------------------------------------------------------------------------------------------------------
# Network Details
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {}

# ---------------------------------------------------------------------------------------------------------------------
# Vpc
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-VPC"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Private Subnets
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-PrivateSubnet-${count.index + 1}"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Public subnets
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-PublicSubnet-${count.index + 1}"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-IGW"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Route for public subnets
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "public-route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  
}

# ---------------------------------------------------------------------------------------------------------------------
# Elastic IP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.stack_name}-eip-${count.index + 1}"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT Gateway
# ---------------------------------------------------------------------------------------------------------------------

# resource "aws_nat_gateway" "nat" {
#   count         = 1
#   subnet_id     = element(aws_subnet.public.*.id, count.index)
#   allocation_id = element(aws_eip.eip.*.id, count.index)

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "${var.stack_name}-NatGateway-${count.index + 1}"
#     }
#   )
# }

# ---------------------------------------------------------------------------------------------------------------------
# Private route table
# ---------------------------------------------------------------------------------------------------------------------

# resource "aws_route_table" "private-route-table" {
#   count  = var.az_count
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
#   }

#   tags = merge(
#     var.common_tags,
#     {
#       Name = "${var.stack_name}-PrivateRouteTable-${count.index + 1}"
#     }
#   )
# }

# resource "aws_route_table_association" "route-association" {
#   count          = var.az_count
#   subnet_id      = element(aws_subnet.private.*.id, count.index)
#   route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
# }
