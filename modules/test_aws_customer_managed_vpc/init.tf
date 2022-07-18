terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints"
    key    = "test_aws_customer_managed_vpc.tfstate"
    region = "us-east-1"
    profile = "aws-field-eng_databricks-power-user"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.22.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "aws-field-eng_databricks-power-user"
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

