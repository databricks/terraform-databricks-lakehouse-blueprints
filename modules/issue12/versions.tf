terraform {
  required_version = ">= 1.1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.0.2"
    }
  }
}
