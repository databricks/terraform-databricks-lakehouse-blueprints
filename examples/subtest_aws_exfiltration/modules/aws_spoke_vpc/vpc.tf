data "aws_availability_zones" "available" {}

/* Create VPC */
resource "aws_vpc" "spoke_vpc" {
  cidr_block           = var.spoke_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-vpc"
  })
}

/* Spoke private subnet for dataplane cluster */
resource "aws_subnet" "spoke_db_private_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc.id
  count                   = length(var.spoke_db_private_subnets_cidr)
  cidr_block              = element(var.spoke_db_private_subnets_cidr, count.index)
  availability_zone_id    = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-db-private-${element(var.azs, count.index)}"
  })
}

/* Spoke private subnet for dataplane cluster */
resource "aws_subnet" "spoke_tgw_private_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc.id
  count                   = length(var.spoke_tgw_private_subnets_cidr)
  cidr_block              = element(var.spoke_tgw_private_subnets_cidr, count.index)
  availability_zone_id    = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-tgw-private-${element(var.azs, count.index)}"
  })
}

/* Routing table for spoke private subnet */
resource "aws_route_table" "spoke_db_private_rt" {
  vpc_id = aws_vpc.spoke_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-db-private-rt"
  })
}

/* Manage the main routing table for VPC  */
resource "aws_main_route_table_association" "spoke-set-worker-default-rt-assoc" {
  vpc_id         = aws_vpc.spoke_vpc.id
  route_table_id = aws_route_table.spoke_db_private_rt.id
}

/* Routing table associations for spoke */
resource "aws_route_table_association" "spoke_db_private_rta" {
  count          = length(var.spoke_db_private_subnets_cidr)
  subnet_id      = element(aws_subnet.spoke_db_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.spoke_db_private_rt.id
}


/* VPC's Default Security Group */
resource "aws_security_group" "default_spoke_sg" {
  name        = "${local.prefix}-default_spoke_sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.spoke_vpc.id
  depends_on  = [aws_vpc.spoke_vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

/* Create VPC Endpoint */
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = aws_vpc.spoke_vpc.id
  security_group_ids = [aws_security_group.default_spoke_sg.id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        aws_route_table.spoke_db_private_rt.id
      ])
      tags = {
        Name = "${local.prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${local.prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${local.prefix}-kinesis-vpc-endpoint"
      }
    },

  }

  tags = var.tags
}
