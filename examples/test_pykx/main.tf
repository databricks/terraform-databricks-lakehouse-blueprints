
// Create Databricks-compliant VPC
module "pykx" {
  source                      = "../../modules/pykx/"
  aws_spoke_databricks_username = var.aws_spoke_databricks_username
  aws_spoke_databricks_password       = var.aws_spoke_databricks_password
  aws_spoke_ws_url = var.aws_spoke_ws_url
  aws_region = var.aws_region
  }

output "module_workspace_url" {
  value = module.pykx.job_url
}