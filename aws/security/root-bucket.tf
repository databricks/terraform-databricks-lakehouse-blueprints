// initialize provider in "MWS" mode to provision new workspace
// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = "${local.prefix}-rootbucket"
  acl    = "private"
  versioning {
    enabled = false
  }
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-rootbucket"
  })
}

resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket             = aws_s3_bucket.root_storage_bucket.id
  ignore_public_acls = true
  depends_on         = [aws_s3_bucket.root_storage_bucket]
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
}

data "template_file" "data" {
  for_each = fileset("${path.module}", "data/e2_restrictive_bucket_${local.region_bucket_policy}.json")
  template = file("${path.module}/${each.value}")
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  for_each = fileset("${path.module}", "data/e2_restrictive_bucket_${local.region_bucket_policy}.json")
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = replace(replace(data.template_file.data[each.value].rendered, "DATABRICKS_ROOT_S3_BUCKET", aws_s3_bucket.root_storage_bucket.bucket), "WORKSPACE_ID",   var.databricks_workspace_id )
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "${local.prefix}-storage"
}