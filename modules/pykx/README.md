# Databricks PyKX Time Series Processing Automation with Terraform

This repository contains Terraform configurations for automating the process of reading KDB data, converting it to Parquet format, and processing it using Databricks and Pandas UDF functions. The implementation leverages PyKX for efficient KDB interaction and Databricks for scalable data processing.

## Overview

The Terraform scripts in this repository automate the creation and configuration of Databricks notebooks and jobs for handling time-series data. The process involves:

1. **Reading Data from KDB**: The first notebook (`read_kdb_save_parquet.py`) reads data from a KDB database.
2. **Converting to Parquet**: The data is then converted to Parquet format for efficient processing.
3. **Time Series Merge and Processing**: The second notebook (`ts_compute_delta_lake.py`) performs time series data merging and processing using Pandas UDFs.
4. **Databricks Job Configuration**: A Databricks workflow is configured to execute these notebooks in sequence, using a shared Databricks jobs cluster.

![PyKX on Delta Lake & Databricks](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/pykx_dbx_architecture.png)


## Terraform Resources and Modules

### Data Sources

- `databricks_current_user`: Determines the current user's information for path configurations.
- `databricks_spark_version`: Fetches the latest Spark version available in Databricks.
- `databricks_node_type`: Retrieves the smallest node type with a local disk for cost efficiency.

### Notebook Resources

Two Databricks notebooks are created using `databricks_notebook` resources:

1. `read_kdb_save_parquet.py`: Located at `/Users/<your email>/01-Load-PyKX-Delta`.
2. `ts_compute_delta_lake.py`: Located at `/Users/<your email>/02-Merge-Q-Time-Series`.

These notebooks are populated with the respective Python scripts from the local module path.

### Databricks Job

The `databricks_job` resource, `process_time_series_liquid_cluster`, is configured to run the above notebooks sequentially on a Databricks cluster. Key configurations include:

- **Job Cluster**: Utilizes the latest Spark version, `r6i.xlarge` nodes, and enables elastic disk with SPOT instances for cost optimization.
- **Tasks**: The job comprises two tasks, `load_data` and `process_data`, each corresponding to a notebook. The `process_data` task depends on the completion of `load_data`.
- **Libraries**: Each task includes necessary Python libraries such as `numpy`, `pandas`, `pyarrow`, `pykx`, `pytz`, and `toml`.

### Output

- `job_url`: Outputs the URL of the created Databricks job, providing easy access to monitor and manage the job execution.



## Terraform configuration:

* Clone the Repository: Clone this repository to your local machine.

* Configure Terraform Variables: Set the required variables in a terraform.tfvars file. This file should be located outside the GitHub project for security reasons.

* Initialize Terraform: Run terraform init to initialize the working directory containing Terraform configuration files.

* Apply Configuration: Execute terraform apply -var-file="<path_to_your_tfvars_file>/terraform.tfvars" to create the resources in your Databricks workspace.

Ensure you have Terraform installed and configured with the necessary provider credentials to interact with your Databricks and AWS environments.

### Key Features

* Automated Data Pipeline: Streamlines the process of reading, converting, and processing time-series data from KDB to Databricks.
* Scalable and Cost-Effective: Utilizes Databricks' scalable infrastructure with cost-effective options like SPOT instances.
* Sequential Task Execution: Ensures orderly processing by configuring task dependencies within the Databricks job.
* Library Management: Automates the installation of required Python libraries for data processing.

### Prerequisites
* Databricks workspace with necessary permissions.
* Terraform installed and configured.
* Access to a KDB database and appropriate credentials for data extraction.