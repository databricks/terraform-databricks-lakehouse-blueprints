resource "databricks_catalog" "sandbox" {
  provider     = databricks.workspace
  metastore_id = databricks_metastore.this.id
  name         = "sandbox"
  comment      = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
  depends_on = [databricks_metastore_assignment.default_metastore]
}

resource "databricks_grants" "sandbox" {
  provider = databricks.workspace
  catalog  = databricks_catalog.sandbox.name
  grant {
    principal  = "Data Scientists"
    privileges = ["USAGE", "CREATE"]
  }
  grant {
    principal  = "Data Engineers"
    privileges = ["USAGE"]
  }
}

resource "databricks_schema" "things" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.sandbox.id
  name         = "things"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_grants" "things" {
  provider = databricks.workspace
  schema   = databricks_schema.things.id
  grant {
    principal  = "Data Engineers"
    privileges = ["USAGE"]
  }
}