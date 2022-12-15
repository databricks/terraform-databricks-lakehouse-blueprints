output "workspace_url" {
  value       = databricks_mws_workspaces.this.workspace_url
  description = "URL for newly created Databricks workspace"
}

output "workspace_id" {
  value       = databricks_mws_workspaces.this.id
  description = "Workspace numeric ID"
}