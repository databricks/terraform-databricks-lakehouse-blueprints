provider "azapi" {
  subscription_id = local.subscription_id
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = azurerm_databricks_workspace.this.workspace_url
}
