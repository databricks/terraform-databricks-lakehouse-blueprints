data "databricks_spark_version" "latest" {
  provider   = databricks.workspace
  depends_on = [module.aws_customer_managed_vpc]
}
data "databricks_node_type" "smallest" {
  provider   = databricks.workspace
  local_disk = true
  depends_on = [module.aws_customer_managed_vpc]

}

resource "databricks_cluster" "unity_sql" {
  provider                = databricks.workspace
  cluster_name            = "Unity SQL"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 60
  enable_elastic_disk     = false
  num_workers             = 2
  aws_attributes {
    availability = "SPOT"
  }
  data_security_mode = "USER_ISOLATION"
  custom_tags        = { "clusterSource" = "lakehouse-blueprints" }
  depends_on         = [module.aws_customer_managed_vpc.workspace_url, module.aws_full_governed_ws.databricks_external_location]
}