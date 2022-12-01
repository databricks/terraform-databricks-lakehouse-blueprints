resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.2.1.0/24"]
}

data "azurerm_client_config" "current" {}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

resource "azurerm_databricks_workspace" "this" {
  name                        = "${local.prefix}-workspace"
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  sku                         = "premium"
  managed_resource_group_name = "${local.prefix}-workspace-rg"
  tags                        = local.tags
}

locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, azurerm_databricks_workspace.this.id)[0]
  resource_group            = regex(local.resource_regex, azurerm_databricks_workspace.this.id)[1]
  databricks_workspace_name = regex(local.resource_regex, azurerm_databricks_workspace.this.id)[2]
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  prefix                    = replace(replace(lower(azurerm_resource_group.this.name), "rg", ""), "-", "")
  tags = {
    Environment = "TF Demo"
    Owner       = lookup(data.external.me.result, "name")
  }
}

module "unity_catalog" {
  source = "../../modules/azure_uc"

  resource_group_id       = azurerm_resource_group.this.id
  workspaces_to_associate = [azurerm_databricks_workspace.this.workspace_id]
}
