variable "aws_metastore_id" {}
variable "aws_spoke_ws_url" {}

variable "aws_hub_ws_url" {}

variable "aws_spoke_databricks_username" {
}
variable "aws_spoke_databricks_password" {
}

variable "aws_hub_databricks_username" {
}
variable "aws_hub_databricks_password" {
}

variable "azure_metastore_id" {}
variable "azure_spoke_ws_url" {}
variable "global_azure_metastoreid" {}
variable "global_aws_metastoreid" {}
variable "global_hub_metastoreid" {}



variable "aws_region" {}

locals {
  prefix = "fs-lakehouse"
}

locals {
  tags = { "org" = "fsi" }
}

locals {
  ext_s3_bucket = "${local.prefix}-ext-bucket"
}