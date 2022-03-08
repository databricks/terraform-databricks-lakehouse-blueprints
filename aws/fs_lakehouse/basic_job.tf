data "databricks_current_user" "me" {}

resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/Terraform"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
    # created from ${abspath(path.module)}
    spark.sql("create database if not exists fsi location 's3://${local.ext_s3_bucket}'")
    spark.read.option("sep", "|").option("header", "true").csv("/tmp").write.mode('overwrite').saveAsTable("fsi.card_txns")
    EOT
  )
}


resource "databricks_job" "this" {
  name = "FSI Terraform Demo (${data.databricks_current_user.me.alphanumeric})"

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id

    spark_conf = {
    "spark.databricks.acl.dfAclsEnabled" : "true",
    "spark.databricks.repl.allowedLanguages" : "python,sql",
  }

    aws_attributes {
    instance_profile_arn   = databricks_instance_profile.shared.id
    availability           = "SPOT"
    zone_id                = "us-east-1"
    first_on_demand        = 1
    spot_bid_price_percent = 100
  }
  }

  notebook_task {
    notebook_path = databricks_notebook.this.path
  }
}

output "notebook_url" {
  value = databricks_notebook.this.url
}

output "job_url" {
  value = databricks_job.this.url
}