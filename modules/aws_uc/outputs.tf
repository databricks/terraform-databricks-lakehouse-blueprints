output "databricks_metastore_id" {
  value = databricks_metastore.this.id
}

output "databricks_storage_credential" {
  value = databricks_storage_credential.external.id
}

output "databricks_external_location" {
  value = databricks_external_location.some.id
}