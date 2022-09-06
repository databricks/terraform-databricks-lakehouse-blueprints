resource "azurerm_resource_group" "this" {
  name     = var.spoke_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "spoke-vnet-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.spoke_vnet_address_space]
}

locals {
  vpcx_location       = data.azurerm_resource_group.vpcx_rg.location
  databricks_location = data.azurerm_resource_group.databricks_rg.location
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_id}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}
