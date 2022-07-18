module "aws_customer_managed_vpc" {
  source = "../aws_customer_managed_vpc/"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  region                      = var.region
  relay_vpce_service          = var.relay_vpce_service
  workspace_vpce_service      = var.workspace_vpce_service
  vpce_subnet_cidr            = var.vpce_subnet_cidr
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  security_group_id           = var.security_group_id
  cross_account_arn           = var.cross_account_arn
}

output "module_workspace_url" {
  value = module.aws_customer_managed_vpc.workspace_url
}
