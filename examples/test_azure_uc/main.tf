data "azurerm_client_config" "current" {}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

module "unity_catalog" {
  source = "../../modules/azure_uc"
  location = var.location
  resource_group_id       = var.resource_group_name
  workspaces_to_associate = var.workspaces_to_associate
  databricks_resource_id = var.databricks_resource_id
}
