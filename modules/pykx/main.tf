data "databricks_current_user" "me" {
}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

resource "databricks_notebook" "load" {
    provider = databricks.spoke_aws_workspace
  source = "${path.module}/read_kdb_save_parquet.py"
  path   = "${data.databricks_current_user.me.home}/01-Load-PyKX-Delta"
}

resource "databricks_notebook" "time_series_merge" {
    provider = databricks.spoke_aws_workspace
  source = "${path.module}/ts_compute_delta_lake.py"
  path   = "${data.databricks_current_user.me.home}/02-Merge-Q-Time-Series"
}


resource "databricks_job" "process_time_series_liquid_cluster" {
  provider = databricks.spoke_aws_workspace
  name = "Databricks PyKX Time Series Merge into Delta Lake (${data.databricks_current_user.me.alphanumeric})"

    job_cluster {
    job_cluster_key = "shared_cap_markets"
    new_cluster {
    spark_version       = data.databricks_spark_version.latest.id
    node_type_id        = "r6i.xlarge"
    enable_elastic_disk = true
    num_workers         = 1
    aws_attributes {
      availability = "SPOT"
    }
    data_security_mode = "SINGLE_USER"
    custom_tags        = { "clusterSource" = "lakehouse-blueprints" }
  }
  }

  task {
    task_key = "load_data"
    notebook_task {
      notebook_path = databricks_notebook.load.path
      }

    job_cluster_key = "shared_cap_markets"

      library {
    pypi {
      package = "numpy~=1.22"
    }
  }

  library {
    pypi {
      package = "pandas>=1.2"
    }
  }
      library {
    pypi {
      package = "pyarrow>=3.0.0"
    }
  }

  library {
    pypi {
      package = "pykx==2.1.1"
    }
  }

      library {
    pypi {
      package = "pytz>=2022.1"
    }
  }

  library {
    pypi {
      package = "toml~=0.10.2"
    }
  }
    }

    task {
    task_key = "process_data"
    //this task will only run after task a
    depends_on {
      task_key = "load_data"
    }

    notebook_task {
      notebook_path = databricks_notebook.time_series_merge.path
      }

    job_cluster_key = "shared_cap_markets"

      library {
    pypi {
      package = "numpy~=1.22"
    }
  }

  library {
    pypi {
      package = "pandas>=1.2"
    }
  }
      library {
    pypi {
      package = "pyarrow>=3.0.0"
    }
  }

  library {
    pypi {
      package = "pykx==2.1.1"
    }
  }

      library {
    pypi {
      package = "pytz>=2022.1"
    }
  }

  library {
    pypi {
      package = "toml~=0.10.2"
    }
  }
  }

  }


output "job_url" {
  value = databricks_job.process_time_series_liquid_cluster.id
}
