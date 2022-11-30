variable "crossaccount_role_name" {
  type        = string
  description = "Role that you've specified on https://accounts.cloud.databricks.com/#aws"
}

variable "workspace_url" {

}
variable "databricks_account_username" {

}

variable "databricks_account_password" {

}

variable "allow_ip_list" {}
variable "use_ip_access_list" {default = true}

locals {
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