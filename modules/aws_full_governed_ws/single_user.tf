resource "databricks_group" "dev" {
  display_name               = "dev-clusters"
  provider = databricks.workspace
}

data "databricks_current_user" "me" {}

resource "databricks_group_member" "dev" {
  group_id  = databricks_group.dev.id
  member_id = data.databricks_current_user.me.id
  provider = databricks.mws
}

data "databricks_user" "dev" {
  provider = databricks.workspace
  for_each = databricks_group.dev
  user_id  = each.key
}

resource "databricks_cluster" "dev" {
  for_each                = data.databricks_user.dev
  provider                = databricks.workspace
  cluster_name            = "${each.value.display_name} unity cluster"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  enable_elastic_disk     = false
  num_workers             = 2
  aws_attributes {
    availability = "SPOT"
  }
  data_security_mode = "SINGLE_USER"
  single_user_name   = each.value.user_name
}

resource "databricks_permissions" "dev_restart" {
  for_each   = data.databricks_user.dev
  provider   = databricks.workspace
  cluster_id = databricks_cluster.dev[each.key].cluster_id
  access_control {
    user_name        = each.value.user_name
    permission_level = "CAN_RESTART"
  }
}