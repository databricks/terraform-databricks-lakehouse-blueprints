resource "databricks_group" "ds_pii" {
  display_name               = "Data Scientist - PII"
  allow_cluster_create       = true
  allow_instance_pool_create = true
}

resource "databricks_group" "da_general" {
  display_name               = "Data Analyst - General"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access = true
}

resource "databricks_group" "de_general" {
  display_name               = "Data Engineer - General"
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access = true
}

resource "databricks_user" "this" {
  user_name = "ricardo@databricks.com"
}

resource "databricks_group_member" "ds_assign" {
  group_id  = databricks_group.ds_pii.id
  member_id = databricks_user.this.id
}

resource "databricks_group_member" "da_assign" {
  group_id  = databricks_group.da_general.id
  member_id = databricks_user.this.id
}

resource "databricks_sql_permissions" "fsi_pii_db" {
  // change this to your specified database
  database = "default"

  privilege_assignments {
    principal  = databricks_group.ds_pii.display_name
    privileges = ["SELECT"]
  }
}