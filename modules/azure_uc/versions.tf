terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.30.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.6.4"
    }
  }
}

