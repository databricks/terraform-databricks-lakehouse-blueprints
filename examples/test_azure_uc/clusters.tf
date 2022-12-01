# data "databricks_spark_version" "latest" {
# }
# data "databricks_node_type" "smallest" {
#   local_disk = true
# }

# resource "databricks_cluster" "unity_sql" {
#   cluster_name            = "Unity SQL"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 60
#   enable_elastic_disk     = false
#   num_workers             = 2
#   azure_attributes {
#     availability = "SPOT"
#   }
#   data_security_mode = "USER_ISOLATION"
#   # need to wait until the metastore is assigned
#   depends_on = [
#     databricks_metastore_assignment.this
#   ]
# }

# data "databricks_group" "dev" {
#   display_name = "dev-clusters"
# }

# data "databricks_user" "dev" {
#   for_each = data.databricks_group.dev.members
#   user_id  = each.key
# }

# resource "databricks_cluster" "dev" {
#   for_each                = data.databricks_user.dev
#   cluster_name            = "${each.value.display_name} unity cluster"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 10
#   num_workers             = 2
#   azure_attributes {
#     availability = "SPOT_WITH_FALLBACK_AZURE"
#   }
#   data_security_mode = "SINGLE_USER"
#   single_user_name   = each.value.user_name
#   # need to wait until the metastore is assigned
#   depends_on = [
#     databricks_metastore_assignment.this
#   ]
# }

# resource "databricks_permissions" "dev_restart" {
#   for_each   = data.databricks_user.dev
#   cluster_id = databricks_cluster.dev[each.key].cluster_id
#   access_control {
#     user_name        = each.value.user_name
#     permission_level = "CAN_RESTART"
#   }
# }
