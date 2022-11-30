terraform {
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