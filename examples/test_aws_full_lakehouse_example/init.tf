terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints2"
    key    = "test_aws_full_lakehouse_example3.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.6.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.35.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


provider "databricks" {
  alias      = "mws"
  account_id = var.databricks_account_id
  host       = "https://accounts.cloud.databricks.com"
  username   = var.databricks_account_username
  password   = var.databricks_account_password
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  alias      = "workspace"
  account_id = var.databricks_account_id

  host     = module.aws_customer_managed_vpc.workspace_url
  username = var.databricks_account_username
  password = var.databricks_account_password
}