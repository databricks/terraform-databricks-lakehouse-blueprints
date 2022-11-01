resource "databricks_storage_credential" "external" {
  provider = databricks.workspace
  name     = aws_iam_role.external_data_access.name
  aws_iam_role {
    role_arn = aws_iam_role.external_data_access.arn
  }
  comment = "Managed by TF"
}

resource "databricks_grants" "external_creds" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.external.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_TABLE"]
  }
}

resource "databricks_external_location" "some" {
  provider        = databricks.workspace
  name            = "external"
  url             = "s3://${aws_s3_bucket.external.id}/some"
  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
}

resource "databricks_grants" "some" {
  provider          = databricks.workspace
  external_location = databricks_external_location.some.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_TABLE", "READ_FILES"]
  }
}