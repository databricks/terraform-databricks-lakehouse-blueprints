/* Create VPC */
resource "aws_vpc" "hub_vpc" {
  cidr_block           = var.hub_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-vpc"
  })
}

/* Private subnet for Hub TGW Databricks */
resource "aws_subnet" "hub_tgw_private_subnet" {
  vpc_id                  = aws_vpc.hub_vpc.id
  count                   = length(local.hub_tgw_private_subnets_cidr)
  cidr_block              = element(local.hub_tgw_private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-tgw-private-${element(local.availability_zones, count.index)}"
  })
}

/* NAT Public subnet */
resource "aws_subnet" "hub_nat_public_subnet" {
  vpc_id                  = aws_vpc.hub_vpc.id
  count                   = length(local.hub_nat_public_subnets_cidr)
  cidr_block              = element(local.hub_nat_public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-nat-public-${element(local.availability_zones, count.index)}"
  })
}

/* Firewall subnet */
resource "aws_subnet" "hub_firewall_subnet" {
  vpc_id                  = aws_vpc.hub_vpc.id
  count                   = length(local.hub_firewall_subnets_cidr)
  cidr_block              = element(local.hub_firewall_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-firewall-public-${element(local.availability_zones, count.index)}"
  })
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "hub_igw" {
  vpc_id = aws_vpc.hub_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-igw"
  })
}

/* Elastic IP for NAT */
resource "aws_eip" "hub_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.hub_igw]
}

/* Hub NAT Gateway */
resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.hub_nat_eip.id
  subnet_id     = element(aws_subnet.hub_nat_public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.hub_igw]
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-nat"
  })
}


/* Routing table for hub private subnet */
resource "aws_route_table" "hub_tgw_private_rt" {
  vpc_id = aws_vpc.hub_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-tgw-private-rt"
  })
}

/* Routing table for hub nat public subnet */
resource "aws_route_table" "hub_nat_public_rt" {
  vpc_id = aws_vpc.hub_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-nat-rt"
  })
}

/* Routing table for spoke nat public subnet */
resource "aws_route_table" "hub_firewall_rt" {
  vpc_id = aws_vpc.hub_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-firewall-rt"
  })
}

/* Routing table for internet gateway */
resource "aws_route_table" "hub_igw_rt" {
  vpc_id = aws_vpc.hub_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-hub-igw-rt"
  })
}

/* Routing table associations for hub tgw */
resource "aws_route_table_association" "hub_tgw_rta" {
  count          = length(local.hub_tgw_private_subnets_cidr)
  subnet_id      = element(aws_subnet.hub_tgw_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.hub_tgw_private_rt.id
}

resource "aws_route_table_association" "hub_nat_rta" {
  count          = length(local.hub_nat_public_subnets_cidr)
  subnet_id      = element(aws_subnet.hub_nat_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.hub_nat_public_rt.id
}

resource "aws_route_table_association" "hub_firewall_rta" {
  count          = length(local.hub_firewall_subnets_cidr)
  subnet_id      = element(aws_subnet.hub_firewall_subnet.*.id, count.index)
  route_table_id = aws_route_table.hub_firewall_rt.id
}

resource "aws_route_table_association" "hub_igw_rta" {
  gateway_id     = aws_internet_gateway.hub_igw.id
  route_table_id = aws_route_table.hub_igw_rt.id
}

/* Adding routes to route tables */
resource "aws_route" "db_private_nat_gtw" {
  route_table_id         = aws_route_table.hub_tgw_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.hub_nat.id
}

resource "aws_route" "db_firewall_public_gtw" {
  route_table_id         = aws_route_table.hub_firewall_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub_igw.id
}

/* Manage the main routing table for VPC  */
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  vpc_id         = aws_vpc.hub_vpc.id
  route_table_id = aws_route_table.hub_firewall_rt.id
}
