data "aws_subnet" "ws_vpc_subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

locals {
  vpc_cidr_blocks = [
    for subnet in data.aws_subnet.ws_vpc_subnets :
    subnet.cidr_block
  ]
}

// security group for data plane VPC endpoints for backend/relay connections
resource "aws_security_group" "dataplane_vpce" {
  name        = "Data Plane VPC endpoint security group"
  description = "Security group shared with relay and workspace endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Inbound rules"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat([var.vpce_subnet_cidr], local.vpc_cidr_blocks)
  }

  ingress {
    description = "Inbound rules"
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = concat([var.vpce_subnet_cidr], local.vpc_cidr_blocks)
  }

  egress {
    description = "Outbound rules"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat([var.vpce_subnet_cidr], local.vpc_cidr_blocks)
  }

  egress {
    description = "Outbound rules"
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = concat([var.vpce_subnet_cidr], local.vpc_cidr_blocks)
  }

  tags = merge(
    data.aws_vpc.prod.tags,
    {
      Name = "${local.prefix}-${data.aws_vpc.prod.id}-pl-vpce-sg-rules"
    },
  )
}
