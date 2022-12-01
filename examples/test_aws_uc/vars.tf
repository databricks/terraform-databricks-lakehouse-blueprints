variable "databricks_account_id" {}

variable "databricks_workspace_url" {
}
variable "databricks_account_username" {
}

variable "databricks_account_password" {
}
variable "databricks_users" {
}
variable "workspaces_to_associate" {}
variable "databricks_metastore_admins" {}
variable "unity_admin_group" {}

variable "region" {
  default = "us-east-1"
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