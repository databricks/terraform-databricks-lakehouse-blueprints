terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.35.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.30.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "hub_ws"
  host     = var.aws_hub_ws_url
  username = var.aws_hub_databricks_username
  password = var.aws_hub_databricks_password
}

// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "spoke_aws_workspace"
  host     = var.aws_spoke_ws_url
  username = var.aws_spoke_databricks_username
  password = var.aws_spoke_databricks_password
}

// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "spoke_azure_workspace"
  host     = var.azure_spoke_ws_url
}