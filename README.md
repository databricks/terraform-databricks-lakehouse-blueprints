# Deploy Your Lakehouse Architecture

## Purpose

This set of terraform templates is designed to allow every industry practitioner and devops team started quickly with the canonical Regulated Industries security best practices and governance setup as well as highly valuable industry libraries and quickstarts directly in your environment.

![Lakehouse Blueprints](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/blueprints.png)

---

## Details on what is Packaged

What's include in this sequence of Terraform modules?

#### AWS | Azure

1. Creation of Databricks-compliant VPC in `aws_base` `azure_spoke_vnet` (AWS | Azure)
2. Platform Security Built in to Workspace deployment (Private Link, VPC endpoints, and secure connectivity) (AWS | Azure)
3. Unity Catalog Installation (AWS | Azure)
4. Industry Quickstarts with Sample Job and Pre-installed Libraries for Time Series, Common Domain Models
5. Full End-to-End example (AWS) for Composition of all modules above (see below). Similarly, this works for Azure modules. 

```hcl
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
```

### Azure-Specific Changes

* Hub and Spoke Architecture with Azure Databricks workspace created per Spoke - The infrastructure deployed matches the design in the Data Exfiltration Prevention blog released by Databricks [here](https://www.databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html)

### GCP

* Bring-your-own-VPC configuration with GCP (see GCP folder)
