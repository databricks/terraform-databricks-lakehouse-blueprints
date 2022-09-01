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

module "databricks_workspace" {
  source                          = "../modules/azure-databricks-workspace"
  workspace_name                  = var.workspace_name
  databricks_resource_group_name  = data.azurerm_resource_group.databricks_rg.name
  vpcx_resource_group_name        = data.azurerm_resource_group.vpcx_rg.name
  location                        = local.databricks_location
  vnet_id                         = data.azurerm_virtual_network.vnet.id
  vnet_name                       = var.vnet_name
  nsg_id                          = azurerm_network_security_group.this.id
  route_table_id                  = azurerm_route_table.this.id
  private_subnet_name             = var.private_subnet_name
  public_subnet_name              = var.public_subnet_name
  private_subnet_address_prefixes = var.private_subnet_address_prefix
  public_subnet_address_prefixes  = var.public_subnet_address_prefix
  tags                            = var.tags
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.databricks_workspace]

  create_duration = "60s"
}

module "databricks_permissions" {
  source               = "../modules/databricks-permissions"
  project_id           = var.project_id
  business_unit        = var.business_unit
  storage_account_name = var.storage_account_name
  client_id            = var.client_id
  client_secret        = var.client_secret
  tenant_id            = var.tenant_id
  db_host              = module.databricks_workspace.workspace_url
  workspace_name       = module.databricks_workspace.workspace_name
  notification_emails  = var.notification_emails
  kv_name              = var.kv_name
  secret_key           = var.secret_key

  depends_on = [time_sleep.wait_60_seconds]
}
