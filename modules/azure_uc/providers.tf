provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

# provider "databricks" {
#   host = local.databricks_workspace_host
# }
