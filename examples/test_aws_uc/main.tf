module "aws_uc" {
  source                      = "../../modules/aws_uc/"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  databricks_users            = var.databricks_users
  databricks_metastore_admins = var.databricks_metastore_admins
  region                      = var.region
  workspaces_to_associate     = var.workspaces_to_associate
  databricks_workspace_url    = var.databricks_workspace_url
  unity_admin_group           = var.unity_admin_group
}