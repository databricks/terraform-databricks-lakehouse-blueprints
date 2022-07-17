variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "databricks_account_id" {}

variable "databricks_workspace_id" {}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "us-east-1"
}

locals {
region_bucket_policy = (
  replace(var.region, "-", "_")
  )
}



resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 5
}

locals {
  prefix = "fsi-ws"
}

