variable "databricks_account_id" {}
variable "databricks_google_service_account" {}

terraform {
 required_providers {
   databricks = {
     source  = "databrickslabs/databricks"
   }
 }
}

resource "databricks_mws_workspaces" "this" {
 provider       = databricks.accounts
 account_id     = var.databricks_account_id
 workspace_name = "ricardo_portilla-demo"
 location       = data.google_client_config.current.region

 cloud_resource_bucket {
   gcp {
     project_id = data.google_client_config.current.project
   }
 }
}
