module "aws_base" {
  source                      = "../../modules/aws_base/"
  cidr_block                      = var.cidr_block
  tags          = var.tags
  region      = var.region
  databricks_account_password = var.databricks_account_password
  databricks_account_id =  var.databricks_account_id
  databricks_account_username =var.databricks_account_username
}

data "aws_vpc" "prod" {
  id    = module.aws_base.vpc_id
}


module "aws_customer_managed_vpc" {
  source                      = "../../modules/aws_customer_managed_vpc/"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  region                      = var.region
  relay_vpce_service          = var.relay_vpce_service
  workspace_vpce_service      = var.workspace_vpce_service
  vpce_subnet_cidr            = cidrsubnet(data.aws_vpc.prod.cidr_block, 3, 3)
  vpc_id                      = module.aws_base.vpc_id
  subnet_ids                  = module.aws_base.subnets
  security_group_id           = module.aws_base.security_group[0]
  cross_account_arn           = module.aws_base.cross_account_role_arn

   providers = {
    databricks = databricks.mws
  }
  depends_on = [module.aws_base]
}


module "aws_full_governed_ws" {
  source                      = "../../modules/aws_full_governed_ws/"
  databricks_account_id = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  region = var.region
  workspaces_to_associate = [split("/", module.aws_customer_managed_vpc.workspace_id)[1]]
  databricks_workspace_url = module.aws_customer_managed_vpc.workspace_url
}


module "aws_fs_lakehouse" {
  source                      = "../../modules/aws_fs_lakehouse/"
  workspace_url       = module.aws_customer_managed_vpc.workspace_url
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  crossaccount_role_name           = split("/", module.aws_base.cross_account_role_arn)[1]
  allow_ip_list = var.allow_ip_list
  use_ip_access_list = var.use_ip_access_list

     providers = {
    databricks = databricks.workspace
  }

  depends_on = [module.aws_full_governed_ws]
}