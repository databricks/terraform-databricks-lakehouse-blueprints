variable "aws_spoke_ws_url" {}


variable "aws_spoke_databricks_username" {
}
variable "aws_spoke_databricks_password" {
}


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