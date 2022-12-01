terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.31.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "= 1.6.5"
    }
  }
}

