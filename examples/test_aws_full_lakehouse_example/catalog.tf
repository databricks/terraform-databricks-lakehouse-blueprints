resource "databricks_catalog" "sandbox" {
  provider     = databricks.workspace
  metastore_id = module.aws_full_governed_ws.databricks_metastore_id
  name         = "sandbox"
  comment      = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
  depends_on = [databricks_group.ds_group_ws, databricks_group.de_group_ws, databricks_group.de_group, databricks_group.ds_group]
}


resource "databricks_schema" "things" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.sandbox.id
  name         = "things"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
  depends_on = [databricks_group.de_group]
}
