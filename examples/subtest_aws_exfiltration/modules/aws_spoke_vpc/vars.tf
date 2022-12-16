variable "tags" {
  default = {}
}

variable "spoke_cidr_block" {
  default = "10.173.0.0/16"
}

variable "spoke_db_private_subnets_cidr" {
  type    = list(string)
  default = ["10.173.4.0/24", "10.173.8.0/24"]
}

variable "spoke_tgw_private_subnets_cidr" {
  type    = list(string)
  default = ["10.173.12.0/24", "10.173.16.0/24"]
}

variable "sg_egress_ports" {
  default = [443, 3306, 6666]
}
variable "sg_ingress_protocol" {
  default = ["tcp", "udp"]
}
variable "sg_egress_protocol" {
  default = ["tcp", "udp"]
}

variable "region" {
  default = "eu-west-1"
}

variable "azs" {
  type    = list(string)
  default = ["euc1-az1", "euc1-az2"]
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "demo${random_string.naming.result}"
}

