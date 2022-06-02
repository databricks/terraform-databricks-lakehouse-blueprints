terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
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
}
