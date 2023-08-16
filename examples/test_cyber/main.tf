
// Create Databricks-compliant VPC
module "multicloud_cyber" {
  source                      = "../../modules/multicloud_cyber/"
  aws_spoke_databricks_username = var.aws_spoke_databricks_username
  aws_spoke_databricks_password       = var.aws_spoke_databricks_password
  aws_hub_databricks_username = var.aws_hub_databricks_username
  aws_hub_databricks_password       = var.aws_hub_databricks_password
  aws_spoke_ws_url = var.aws_spoke_ws_url
  aws_hub_ws_url = var.aws_hub_ws_url
  azure_spoke_ws_url = var.azure_spoke_ws_url
  azure_metastore_id = var.azure_metastore_id
  aws_metastore_id = var.aws_metastore_id
  aws_region = var.aws_region
  global_azure_metastoreid = var.global_azure_metastoreid
  global_aws_metastoreid = var.global_aws_metastoreid
  global_hub_metastoreid = var.global_hub_metastoreid
}

output "module_workspace_url" {
  value = module.multicloud_cyber.job_url
}

output "azure_workspace_url" {
  value = module.multicloud_cyber.azure_job_url
}

output "dbfs_path" {
  value = module.multicloud_cyber.dbfs_path
}