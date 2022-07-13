variable "databricks_account_id" {}
variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "region" {}

variable "workspace_vpce_service" {}
variable "relay_vpce_service" {}
variable "vpce_subnet_cidr" {}

variable "private_dns_enabled" { default = true}
variable "tags" { default = {}}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

locals {
  prefix = "private-link-ws"
}