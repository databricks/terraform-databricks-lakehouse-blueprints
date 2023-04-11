resource "databricks_directory" "solacc" {
  path = "/Repos/SolutionAccelerators"
}

resource "databricks_repo" "smolder" {
  url  = "https://github.com/databricks-industry-solutions/smolder-solacc.git"
  path = "${databricks_directory.solacc.path}/smolder"
}

resource "databricks_repo" "dbignite" {
  url  = "https://github.com/databricks-industry-solutions/interop.git"
  path = "${databricks_directory.solacc.path}/dbignite"
}

resource "databricks_repo" "omop" {
  url  = "https://github.com/databricks-industry-solutions/omop-cdm.git"
  path = "${databricks_directory.solacc.path}/omop"
}

resource "databricks_repo" "pixels" {
  url  = "https://github.com/databricks-industry-solutions/pixels.git"
  path = "${databricks_directory.solacc.path}/pixels"
}

resource "databricks_permissions" "smolder_usage" {
  repo_id = databricks_repo.smolder.id

  access_control {
    group_name       = "users"
    permission_level = "CAN_RUN"
  }
}

resource "databricks_permissions" "dbignite_usage" {
  repo_id = databricks_repo.dbignite.id

  access_control {
    group_name       = "users"
    permission_level = "CAN_RUN"
  }
}

resource "databricks_permissions" "omop_usage" {
  repo_id = databricks_repo.omop.id

  access_control {
    group_name       = "users"
    permission_level = "CAN_RUN"
  }
}

resource "databricks_permissions" "pixels_usage" {
  repo_id = databricks_repo.pixels.id

  access_control {
    group_name       = "users"
    permission_level = "CAN_RUN"
  }
}
