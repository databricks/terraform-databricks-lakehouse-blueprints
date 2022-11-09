locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, var.databricks_resource_id)[0]
  resource_group            = regex(local.resource_regex, var.databricks_resource_id)[1]
  databricks_workspace_name = regex(local.resource_regex, var.databricks_resource_id)[2]
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  databricks_workspace_host = data.azurerm_databricks_workspace.this.workspace_url
  databricks_workspace_id   = data.azurerm_databricks_workspace.this.workspace_id
  prefix                    = replace(replace(lower(data.azurerm_resource_group.this.name), "rg", ""), "-", "")
}

data "azurerm_resource_group" "this" {
  name = local.resource_group
}

data "azurerm_client_config" "current" {
}

data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

resource "azapi_resource" "access_connector" {
  type      = "Microsoft.Databricks/accessConnectors@2022-04-01-preview"
  name      = "${local.prefix}-databricks-mi"
  location  = data.azurerm_resource_group.this.location
  parent_id = data.azurerm_resource_group.this.id
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {}
  })
}

resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}storage"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  tags                     = data.azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.access_connector.identity[0].principal_id
}

resource "databricks_metastore" "this" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  force_destroy = true
}

resource "databricks_metastore_data_access" "first" {
  metastore_id = databricks_metastore.this.id
  name         = "the-keys"
  azure_managed_identity {
    access_connector_id = azapi_resource.access_connector.id
  }

  is_default = true
}

resource "databricks_metastore_assignment" "this" {
  workspace_id         = local.databricks_workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}

