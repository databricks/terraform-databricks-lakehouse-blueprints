// Create Databricks-compliant VPC
module "aws_base" {
  source                      = "../../modules/aws_base/"
  cidr_block                  = var.cidr_block
  tags                        = var.tags
  region                      = var.region
  databricks_account_password = var.databricks_account_password
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
}

data "aws_vpc" "prod" {
  id = module.aws_base.vpc_id
}

module "databricks_cmk" { // using cmk module developed by andrew.weaver@databricks.com
  source                 = "./modules/databricks_cmk"
  cross_account_role_arn = module.aws_base.cross_account_role_arn
  resource_prefix        = local.prefix
  region                 = var.region
  cmk_admin              = var.cmk_admin
}

// Deploy Workspace Using Above-created VPC subnets and infrastructure
module "aws_customer_managed_vpc" {
  source                      = "./modules/aws_customer_managed_vpc_cmk_ws/"
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
  workspace_storage_cmk       = module.databricks_cmk.workspace_storage_cmk
  managed_services_cmk        = module.databricks_cmk.managed_services_cmk

  providers = {
    databricks = databricks.mws
  }
  depends_on = [module.aws_base]
}

// Enable UC for the workspace aboves
module "aws_uc" {
  source                      = "../../modules/aws_uc/"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  region                      = var.region
  workspaces_to_associate     = [split("/", module.aws_customer_managed_vpc.workspace_id)[1]]
  databricks_workspace_url    = module.aws_customer_managed_vpc.workspace_url
}
