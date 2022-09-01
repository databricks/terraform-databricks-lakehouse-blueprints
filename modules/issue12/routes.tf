# webapp
# scc relays
# ext-infra
# service tags: AzureDatabricks, EventHub, SQL, Storage
# ipinfo/ganglia
# pypi/cran

locals {
  title_cased_location = title(var.location)
  service_tags = {
    "databricks" : { "tag" : "AzureDatabricks", "port" : "443" },
    "sql" : { "tag" : "Sql.${local.title_cased_location}", "port" : "3306" },
    "storage" : { "tag" : "Storage.${local.title_cased_location}", "port" : "443" },
    "eventhub" : { "tag" : "EventHub.${local.title_cased_location}", "port" : "9093" }
  }
}

resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "databricks_routes" {
  for_each            = var.routes
  name                = each.key
  resource_group_name = data.azurerm_resource_group.vpcx_rg.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type
}

resource "azurerm_route" "scc_routes" {
  count               = length(var.scc_relay_address_prefixes)
  name                = "to-SCC-relay-ip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
  address_prefix      = var.scc_relay_address_prefixes[count.index]
  next_hop_type       = "Internet"
}

resource "azurerm_route" "firewall_routes" {
  for_each               = var.firewall_routes
  name                   = each.key
  resource_group_name    = data.azurerm_resource_group.vpcx_rg.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}
