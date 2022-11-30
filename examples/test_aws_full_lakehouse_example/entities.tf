data "databricks_user" "this" {
  provider   = databricks.mws
  for_each   = toset(concat(var.databricks_users, var.databricks_metastore_admins))
  user_name  = each.key
  depends_on = [module.aws_fs_lakehouse]
}

resource "databricks_group" "admin_group" {
  provider     = databricks.mws
  display_name = var.unity_admin_group
}


resource "databricks_group" "de_group" {
  provider     = databricks.mws
  display_name = "Data Engineers"
}

resource "databricks_group" "ds_group" {
  provider     = databricks.mws
  display_name = "Data Scientists"
}


// due to this issue we are instantiating at the workspace level also - https://github.com/databricks/terraform-provider-databricks/issues/1773
resource "databricks_group" "de_group_ws" {
  provider     = databricks.workspace
  display_name = "Data Engineers"
}

resource "databricks_group" "ds_group_ws" {
  provider     = databricks.workspace
  display_name = "Data Scientists"
}


resource "databricks_group_member" "admin_group_member" {
  provider  = databricks.mws
  for_each  = data.databricks_user.this
  group_id  = databricks_group.admin_group.id
  member_id = each.value.id
}

resource "databricks_user_role" "metastore_admin" {
  provider = databricks.mws
  for_each = toset(var.databricks_metastore_admins)
  user_id  = data.databricks_user.this[each.value].id
  role     = "account_admin"
}