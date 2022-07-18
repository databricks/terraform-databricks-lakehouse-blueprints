variable "databricks_account_id" {}
variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "region" {}

variable "workspace_vpce_service" {}
variable "relay_vpce_service" {}
variable "vpce_subnet_cidr" {}

<<<<<<< HEAD
variable "private_dns_enabled" {
  default = true
}
variable "tags" {
  default = {}
}
=======
variable "private_dns_enabled" { default = true}
variable "tags" { default = {}}
>>>>>>> d7d0625 (add new files for module)

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "vpc_id" {}
variable "subnet_ids" {
<<<<<<< HEAD
  type = list(string)
=======
  type=list(string)
>>>>>>> d7d0625 (add new files for module)
}
variable "security_group_id" {}

variable "cross_account_arn" {}

locals {
  prefix = "private-link-ws"
<<<<<<< HEAD
}
=======
}
>>>>>>> d7d0625 (add new files for module)
