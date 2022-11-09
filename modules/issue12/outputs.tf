output "workspace_name" {
  value = module.databricks_workspace.workspace_name
}

output "databricks_host" {
  value = "https://${module.databricks_workspace.workspace_url}/"
}
