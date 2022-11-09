locals {
  title_cased_location = title(var.location)
  service_tags = {
    "adb" : { "tag" : "AzureDatabricks", "port" : "443" },
    "adb-metastore" : { "tag" : "Sql.${local.title_cased_location}", "port" : "3306" },
    "adb-storage" : { "tag" : "Storage.${local.title_cased_location}", "port" : "443" },
    "adb-eventhub" : { "tag" : "EventHub.${local.title_cased_location}", "port" : "9093" }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "spoke-rg-${var.project_name}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "spoke-vnet-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_route" "service_tags" {
  for_each            = local.service_tags
  name                = each.key
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = each.value.tag
  next_hop_type       = "Internet"
}

resource "azurerm_route" "scc_routes" {
  count               = length(var.scc_relay_address_prefixes)
  name                = "to-SCC-relay-ip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = var.scc_relay_address_prefixes[count.index]
  next_hop_type       = "Internet"
}

resource "azurerm_route" "webapp_routes" {
  count               = length(var.webapp_address_prefixes)
  name                = "to-webapp-ip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = var.webapp_address_prefixes[count.index]
  next_hop_type       = "Internet"
}

resource "azurerm_route" "ext_infra_routes" {
  count               = length(var.extended_infrastructure_address_prefixes)
  name                = "to-ext-infra-ip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = var.extended_infrastructure_address_prefixes[count.index]
  next_hop_type       = "Internet"
}

module "databricks_workspace" {
  source                          = "databricks/lakehouse-blueprints/databricks//modules/azure_vnet_injected_databricks_workspace"
  version                         = "0.0.4"
  workspace_name                  = var.databricks_workspace_name
  databricks_resource_group_name  = azurerm_resource_group.this.name
  location                        = azurerm_virtual_network.this.location
  vnet_id                         = azurerm_virtual_network.this.id
  vnet_name                       = azurerm_virtual_network.this.name
  nsg_id                          = azurerm_network_security_group.this.id
  route_table_id                  = azurerm_route_table.this.id
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  tags                            = var.tags
}
