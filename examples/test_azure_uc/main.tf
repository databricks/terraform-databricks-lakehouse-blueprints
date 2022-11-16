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

  resource_group_id = azurerm_resource_group.this.id
}

resource "databricks_metastore_assignment" "this" {
  workspace_id         = azurerm_databricks_workspace.this.id
  metastore_id         = module.unity_catalog.databricks_metastore_id
  default_catalog_name = "hive_metastore"
}

# TODO: fix the db workspace module so that it only takes in a vnet id, then derives name/location etc. like in 'locals' below 
# module "databricks_workspace" {
#   source  = "databricks/lakehouse-blueprints/databricks//modules/azure_vnet_injected_databricks_workspace"
#   version = "0.0.5"

#   workspace_name                  = format("%s-databricks", local.prefix)
#   databricks_resource_group_name  = azurerm_resource_group.this.name
#   location                        = azurerm_resource_group.this.location
#   vnet_id                         = azurerm_virtual_network.this.id
#   vnet_name                       = azurerm_virtual_network.this.name
#   nsg_id                          = module.spoke_vnet.nsg_id
#   route_table_id                  = module.spoke_vnet.route_table_id
#   private_subnet_address_prefixes = var.private_subnet_address_prefixes
#   public_subnet_address_prefixes  = var.public_subnet_address_prefixes
#   tags                            = azurerm_resource_group.tags
# }

