output "spoke_tgw_private_subnet" {
  value       = aws_subnet.spoke_tgw_private_subnet[*].id
  description = "spoke vpc tgw subnets"
}

output "spoke_vpc_id" {
  value       = aws_vpc.spoke_vpc.id
  description = "spoke vpc id"
}

output "spoke_db_private_rt" {
  value       = aws_route_table.spoke_db_private_rt.id
  description = "spoke db private route table"
}

output "spoke_db_private_subnets_id" {
  value       = aws_subnet.spoke_db_private_subnet[*].id
  description = "spoke db private subnets"
}

output "default_spoke_sg" {
  value       = aws_security_group.default_spoke_sg.id
  description = "value of default spoke security group"
}
