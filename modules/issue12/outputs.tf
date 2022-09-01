output "nsg_name" {
  value = azurerm_network_security_group.this.name
}

output "route_table_name" {
  value = azurerm_route_table.this.name
}

output "workspace_name" {
  value = module.databricks_workspace.workspace_name
}

output "databricks_host" {
  value = "https://${module.databricks_workspace.workspace_url}/"
}
