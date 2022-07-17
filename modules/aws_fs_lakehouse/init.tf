terraform {
  backend "s3" {
<<<<<<< HEAD
<<<<<<<< HEAD:modules/aws_fs_lakehouse/init.tf
    bucket = "databricks-terraform-blueprints-aws-fs-lakehouse"
    key = "aws_regulated_lakehouse.tfstate"
========
    bucket = "databricks-terraform-blueprints"
    key = "aws_customer_managed_vpc.tfstate"
>>>>>>>> d7d0625 (add new files for module):modules/aws_customer_managed_vpc/init.tf
=======
    bucket = "databricks-terraform-blueprints-aws-fs-lakehouse"
    key = "aws_regulated_lakehouse.tfstate"
>>>>>>> d7d0625 (add new files for module)
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "databricks" {
  host     = var.workspace_url
  username = var.databricks_account_username
  password = var.databricks_account_password
} # Authenticate using preferred method as described in Databricks provider
