module "aws_base" {
  source                      = "../../modules/aws_base/"
  cidr_block                      = var.cidr_block
  tags          = var.tags
  region      = var.region
  databricks_account_password = var.databricks_account_password
  databricks_account_id =  var.databricks_account_id
  databricks_account_username =var.databricks_account_username
}

output "security_group" {
  value       = [module.aws_base.security_group]
  description = "Security group ID for DB Compliant VPC"
}

output "vpc_id" {
  value       = module.aws_base.vpc_id
  description = "VPC ID"
}

output "subnets"  {
  value = module.aws_base.subnets
  description = "private subnets for workspace creation"
}

output "cross_account_role_arn" {
  value = module.aws_base.cross_account_role_arn
  description = "Cross account IAM role for Databricks workspace deployment"
}

output "root_bucket" {
  value = module.aws_base.root_bucket
  description = "root bucket"
}