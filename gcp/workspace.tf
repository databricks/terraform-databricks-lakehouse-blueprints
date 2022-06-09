variable "databricks_account_id" {}
variable "databricks_google_service_account" {}

terraform {
 required_providers {
   databricks = {
     source  = "databrickslabs/databricks"
   }
 }
}

data "google_client_openid_userinfo" "me" {
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
  depends_on = [google_access_context_manager_service_perimeter.test-access]
}

provider "databricks" {
 alias                  = "workspace"
 host                   = databricks_mws_workspaces.this.workspace_url
 google_service_account = var.databricks_google_service_account
}

data "databricks_group" "admins" {
 depends_on   = [databricks_mws_workspaces.this]
 provider     = databricks.workspace
 display_name = "admins"
}

resource "databricks_user" "me" {
 depends_on = [databricks_mws_workspaces.this]

 provider  = databricks.workspace
 user_name = data.google_client_openid_userinfo.me.email
}

resource "databricks_group_member" "allow_me_to_login" {
 depends_on = [databricks_mws_workspaces.this]

 provider  = databricks.workspace
 group_id  = data.databricks_group.admins.id
 member_id = databricks_user.me.id
}

