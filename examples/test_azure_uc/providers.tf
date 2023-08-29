provider "azurerm" {
  features {}
}

provider "databricks" {
  host = var.workspace_url
}
