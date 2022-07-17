terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints"
    key = "test_aws_customer_managed_vpc.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "0.5.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.49.0"
    }
  }
}

provider "aws" {
  region = var.region
}

// initialize provider in "MWS" mode for provisioning workspace with AWS PrivateLink
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

