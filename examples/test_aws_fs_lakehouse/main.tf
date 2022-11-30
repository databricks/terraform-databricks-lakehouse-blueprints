module "aws_fs_lakehouse" {
  source = "../../modules/aws_fs_lakehouse/"

  workspace_url               = var.workspace_url
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  crossaccount_role_name      = var.crossaccount_role_name
  allow_ip_list               = var.allow_ip_list
}