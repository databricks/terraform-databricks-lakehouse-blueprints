terraform {
  backend "s3" {
    bucket  = "databricks-terraform-blueprints2"
    key     = "test_aws_fs_lakehouse.tfstate"
    region  = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0.0"
    }
     aws = {
      source  = "hashicorp/aws"
      version = "~>4.35.0"
    }
  }
}

provider "aws" {
  region = local.region
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  host     = var.workspace_url
  username = var.databricks_account_username
  password = var.databricks_account_password
}