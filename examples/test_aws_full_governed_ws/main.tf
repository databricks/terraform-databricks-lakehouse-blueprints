module "aws_full_governed_ws" {
  source                      = "../../modules/aws_full_governed_ws/"
  databricks_account_id = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  databricks_users = var.databricks_users
  databricks_metastore_admins = var.databricks_metastore_admins
  databricks_workspace_ids = var.databricks_workspace_ids
  databricks_workspace_url = var.databricks_workspace_url
  unity_admin_group = var.unity_admin_group
}