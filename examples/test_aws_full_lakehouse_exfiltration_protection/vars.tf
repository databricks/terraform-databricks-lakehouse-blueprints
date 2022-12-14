variable "databricks_account_id" {}
variable "databricks_account_username" {
}
variable "databricks_account_password" {
}
variable "databricks_users" {
}
variable "databricks_metastore_admins" {}
variable "unity_admin_group" {}

variable "allow_ip_list" { default = ["0.0.0.0/0"] }

variable "use_ip_access_list" { default = true }

variable "region" {}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "workspace_vpce_service" {}
variable "relay_vpce_service" {}

variable "private_dns_enabled" {
  default = true
}

locals {
  prefix = "fs-lakehouse"
}

locals {
  tags = { "org" = "fsi" }
}

locals {
  ext_s3_bucket = "${local.prefix}-ext-bucket"
}
