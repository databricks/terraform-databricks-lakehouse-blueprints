
data "databricks_current_user" "me" {
}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

# Upload the local Python file to DBFS (Databricks File System)
resource "databricks_dbfs_file" "aws_python_file" {
    provider = databricks.spoke_aws_workspace

  source  = "${path.module}/aws_spoke_load.py"
  path  = "/PythonFiles/aws_spoke_load.py"
}


# Upload the local Python file to DBFS (Databricks File System)
resource "databricks_dbfs_file" "azure_python_file" {
  provider = databricks.spoke_azure_workspace
  source  = "${path.module}/azure_spoke_load.py"
  path  = "/PythonFiles/azure_spoke_load.py"
}


resource "databricks_job" "load_azure" {
  provider = databricks.spoke_azure_workspace
  name = "Load Data Azure (${data.databricks_current_user.me.alphanumeric})"

  task {
    task_key = "load_data"
    spark_python_task {
      python_file = join("", ["dbfs:", databricks_dbfs_file.azure_python_file.path])
      }
     new_cluster {
    spark_version       = data.databricks_spark_version.latest.id
    node_type_id        = "Standard_DS3_v2"
    enable_elastic_disk = false
    num_workers         = 1
    data_security_mode = "SINGLE_USER"
    custom_tags        = { "clusterSource" = "lakehouse-blueprints" }
  }
    }
}

resource "databricks_job" "load_aws" {
  provider = databricks.spoke_aws_workspace
  name = "Load Data AWS (${data.databricks_current_user.me.alphanumeric})"

  task {
    task_key = "load_data"
    spark_python_task {
      python_file = join("", ["dbfs:", databricks_dbfs_file.aws_python_file.path])
      }
     new_cluster {
    spark_version       = data.databricks_spark_version.latest.id
    node_type_id        = "r3.xlarge"
    enable_elastic_disk = false
    num_workers         = 1
    aws_attributes {
      availability = "SPOT"
    }
    data_security_mode = "SINGLE_USER"
    custom_tags        = { "clusterSource" = "lakehouse-blueprints" }
  }
    }
  }


output "job_url" {
  value = databricks_job.load_aws.name
}

output "azure_job_url" {
  value = databricks_job.load_azure.name
}

output "dbfs_path" {
  value = databricks_dbfs_file.aws_python_file.path
}

data "databricks_tables" "aws_cyber_tables" {
  provider = databricks.spoke_aws_workspace
  catalog_name = "cyber_catalog"
  schema_name  = "ioc_matching_${split("@", var.aws_hub_databricks_username)[0]}"
  depends_on = [databricks_job.load_aws, databricks_job.load_azure]
}

data "databricks_tables" "azure_cyber_tables" {
  provider = databricks.spoke_azure_workspace
  catalog_name = "cyber_catalog"
  schema_name  = "ioc_matching_${split("@", var.aws_hub_databricks_username)[0]}"
  depends_on = [databricks_job.load_azure]
}

resource "databricks_share" "aws_share" {
  provider = databricks.spoke_aws_workspace
  name = "share_aws_cyber"
  dynamic "object" {
    for_each = data.databricks_tables.aws_cyber_tables.ids
    content {
      name             = object.value
      data_object_type = "TABLE"
    }
  }
}

resource "databricks_share" "azure_share" {
  provider = databricks.spoke_azure_workspace
  name = "share_azure_cyber"
  dynamic "object" {
    for_each = data.databricks_tables.azure_cyber_tables.ids
    content {
      name             = object.value
      data_object_type = "TABLE"
    }
  }
}


resource "databricks_recipient" "aws_hub_recipient_db2db" {
  provider=databricks.spoke_aws_workspace
  name                               = "hub-aws-recipient"
  comment                            = "made by terraform"
  authentication_type                = "DATABRICKS"
  data_recipient_global_metastore_id = var.global_hub_metastoreid
}

resource "databricks_recipient" "azure_hub_recipient_db2db" {
  provider=databricks.spoke_azure_workspace
  name                               = "hub-azure-recipient"
  comment                            = "made by terraform"
  authentication_type                = "DATABRICKS"
  data_recipient_global_metastore_id = var.global_hub_metastoreid
}

resource "databricks_grants" "grant_aws_share" {
  provider=databricks.spoke_aws_workspace
  share = databricks_share.aws_share.name
  grant {
    principal  = databricks_recipient.aws_hub_recipient_db2db.name
    privileges = ["SELECT"]
  }
  depends_on = [databricks_share.aws_share, databricks_recipient.aws_hub_recipient_db2db]
}

resource "databricks_grants" "grant_azure_share" {
  provider=databricks.spoke_azure_workspace
  share = databricks_share.azure_share.name
  grant {
    principal  = databricks_recipient.azure_hub_recipient_db2db.name
    privileges = ["SELECT"]
  }
  depends_on = [databricks_share.azure_share, databricks_recipient.azure_hub_recipient_db2db]
}

resource "databricks_catalog" "aws_spoke_share" {
  provider = databricks.hub_ws
  metastore_id = var.aws_metastore_id
  name         = "aws_spoke_share"

  provider_name = var.global_aws_metastoreid
  share_name = "share_aws_cyber"

}

resource "databricks_catalog" "azure_spoke_share" {
    provider = databricks.hub_ws

  name         = "azure_spoke_share"

  metastore_id = var.aws_metastore_id
  provider_name = "treasury-east"
  share_name = "share_azure_cyber"

}