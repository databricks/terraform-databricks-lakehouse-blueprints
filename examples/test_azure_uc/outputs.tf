output "databricks_metastore_id" {
  value = module.unity_catalog.databricks_metastore_id
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

output "databricks_id" {
  value = azurerm_databricks_workspace.this.workspace_id
}
