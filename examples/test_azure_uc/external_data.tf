resource "azapi_resource" "ext_access_connector" {
  type      = "Microsoft.Databricks/accessConnectors@2022-04-01-preview"
  name      = "ext-databricks-mi"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {}
  })
}

resource "azurerm_storage_account" "ext_storage" {
  name                     = "${local.prefix}extstorage"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  tags                     = azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "ext_storage" {
  name                  = "${local.prefix}-ext"
  storage_account_name  = azurerm_storage_account.ext_storage.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "ext_storage" {
  scope                = azurerm_storage_account.ext_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.ext_access_connector.identity[0].principal_id
}

resource "databricks_storage_credential" "external" {
  name = azapi_resource.ext_access_connector.name
  azure_managed_identity {
    access_connector_id = azapi_resource.ext_access_connector.id
  }
  comment = "Managed by TF"
}

resource "databricks_grants" "external_creds" {
  storage_credential = databricks_storage_credential.external.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_TABLE"]
  }
}

resource "databricks_external_location" "some" {
  name = "external"
  url = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.ext_storage.name,
  azurerm_storage_account.ext_storage.name)

  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
}

resource "databricks_grants" "some" {
  external_location = databricks_external_location.some.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_TABLE", "READ_FILES"]
  }
}
