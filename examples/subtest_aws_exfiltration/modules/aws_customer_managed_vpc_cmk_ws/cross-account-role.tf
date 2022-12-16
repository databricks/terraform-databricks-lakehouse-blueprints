resource "databricks_mws_credentials" "this" {
  account_id       = var.databricks_account_id
  role_arn         = var.cross_account_arn
  credentials_name = "${local.prefix}-credentials"
}