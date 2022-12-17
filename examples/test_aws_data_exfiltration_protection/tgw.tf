//Create transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for Hub/Spoke"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = merge(var.tags, {
    Name = "${local.prefix}-tgw"
  })
}

# Attach Transit VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  subnet_ids         = aws_subnet.hub_tgw_private_subnet[*].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.hub_vpc.id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "${local.prefix}-hub"
    Purpose = "Transit Gateway Attachment - Hub VPC"
  })
}

//# Attach Spoke VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  subnet_ids         = module.db_spoke_vpc.spoke_tgw_private_subnet
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.db_spoke_vpc.spoke_vpc_id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "${local.prefix}-spoke"
    Purpose = "Transit Gateway Attachment - Spoke VPC"
  })
}


# Create Route to Internet
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

# Add route for spoke db to tgw
resource "aws_route" "spoke_db_to_tgw" {
  route_table_id         = module.db_spoke_vpc.spoke_db_private_rt
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [module.db_spoke_vpc, aws_vpc.hub_vpc]
}

resource "aws_route" "hub_tgw_private_subnet_to_tgw" {
  route_table_id         = aws_route_table.hub_tgw_private_rt.id
  destination_cidr_block = var.spoke_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [module.db_spoke_vpc, aws_vpc.hub_vpc]
}

resource "aws_route" "hub_nat_to_tgw" {
  route_table_id         = aws_route_table.hub_nat_public_rt.id
  destination_cidr_block = var.spoke_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [module.db_spoke_vpc, aws_vpc.hub_vpc]
}
