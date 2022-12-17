module "db_spoke_vpc" {
  source                         = "./modules/aws_spoke_vpc"
  spoke_cidr_block               = var.spoke_cidr_block
  spoke_db_private_subnets_cidr  = local.spoke_db_private_subnets_cidr
  spoke_tgw_private_subnets_cidr = local.spoke_tgw_private_subnets_cidr
  sg_egress_ports                = local.sg_egress_ports
  sg_ingress_protocol            = local.sg_ingress_protocol
  sg_egress_protocol             = local.sg_egress_protocol
  region                         = var.region
  azs                            = var.azs
}

module "aws_base" { // creates iam role and root bucket
  source                      = "./modules/aws_base_no_vpc/"
  tags                        = var.tags
  region                      = var.region
  databricks_account_password = var.databricks_account_password
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
}


module "databricks_cmk" { // using cmk module developed by andrew.weaver@databricks.com
  source                 = "./modules/aws_databricks_cmk/"
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
  vpce_subnet_cidr            = var.vpce_subnet_cidr
  vpc_id                      = module.db_spoke_vpc.spoke_vpc_id
  subnet_ids                  = module.db_spoke_vpc.spoke_db_private_subnets_id
  security_group_id           = module.db_spoke_vpc.default_spoke_sg
  cross_account_arn           = module.aws_base.cross_account_role_arn
  workspace_storage_cmk       = module.databricks_cmk.workspace_storage_cmk
  managed_services_cmk        = module.databricks_cmk.managed_services_cmk

  providers = {
    databricks = databricks.mws
  }
  depends_on = [module.aws_base]
}
