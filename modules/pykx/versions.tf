terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.54.0"
    }
  }
}

// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "spoke_aws_workspace"
  host     = var.aws_spoke_ws_url
  username = var.aws_spoke_databricks_username
  password = var.aws_spoke_databricks_password
}

provider "aws" {
  region = "us-east-1"
}

