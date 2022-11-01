variable "databricks_account_id" {}

variable "databricks_workspace_url" {
}
variable "databricks_account_username" {
}

variable "databricks_account_password" {
}
variable "databricks_users" {
}
variable "databricks_workspace_ids" {}
variable "databricks_metastore_admins" {}
variable "unity_admin_group" {}

variable "allow_ip_list" {default = ["*"]}

variable "use_ip_access_list" {default = true}

locals  {
  region = "us-east-1"
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