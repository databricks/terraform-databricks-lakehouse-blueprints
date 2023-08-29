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

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = format("from-%s-to-%s-peer", azurerm_virtual_network.this.name, var.hub_vnet_name)
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = var.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = format("from-%s-to-%s-peer", var.hub_vnet_name, azurerm_virtual_network.this.name)
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "firewall_route" {
  name                   = "to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_route" "scc_routes" {
  count               = length(var.scc_relay_address_prefixes)
  name                = "to-SCC-relay-ip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = var.scc_relay_address_prefixes[count.index]
  next_hop_type       = "Internet"
}

# Create storage account
resource "azurerm_storage_account" "external_storage_example" {
  name                     = "blueprintsa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Firewall Settings
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1", "100.0.0.2"]
    virtual_network_subnet_ids = []
  }
}

# Create storage container
resource "azurerm_storage_container" "external_container_example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}