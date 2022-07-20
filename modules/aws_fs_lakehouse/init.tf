terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints-aws-fs-lakehouse"
    key    = "aws_regulated_lakehouse.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source = "databricks/databricks"
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
