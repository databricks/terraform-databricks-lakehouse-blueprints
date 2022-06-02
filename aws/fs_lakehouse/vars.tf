variable "crossaccount_role_name" {
  type        = string
  description = "Role that you've specified on https://accounts.cloud.databricks.com/#aws"
}

locals  {
  region = "us-east-1"
}

locals {
prefix = "fs-lakehouse"
}

locals {
	tags = {"org"="fsi"}
}

locals {
  ext_s3_bucket = "${local.prefix}-ext-bucket"
}