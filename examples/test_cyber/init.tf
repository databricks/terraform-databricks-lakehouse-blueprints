terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints2"
    key    = "test_cyber_example.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.23.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.31.0"
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

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  alias      = "aws_spoke"

  host     = var.aws_spoke_ws_url
  username = var.aws_spoke_databricks_username
  password = var.aws_spoke_databricks_password
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  alias      = "azure_spoke"
  host     = var.azure_spoke_ws_url
}