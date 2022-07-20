resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  prefix = "databricksdemo${random_string.naming.result}"
  tags = {
    Environment = "Demo"
    Owner       = lookup(data.external.me.result, "name")
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = var.resource_group_location
  resource_group_name = var.azurerm_resource_group_name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]



  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "public" {
  name                 = "${var.dbname}-public-subnet"
  resource_group_name  = var.azurerm_resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "databricks_public"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.dbname}-public-databricks-nsg"
  resource_group_name = var.azurerm_resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_subnet_network_security_group_association" "nsga_public" {
  network_security_group_id = azurerm_network_security_group.public_nsg.id
  subnet_id                 = azurerm_subnet.public.id
}

resource "azurerm_subnet" "private" {
  name                 = "${var.dbname}-private-subnet"
  resource_group_name  = var.azurerm_resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "databricks_private"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = "${var.dbname}-private-databricks-nsg"
  resource_group_name = var.azurerm_resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_subnet_network_security_group_association" "nsga_private" {
  network_security_group_id = azurerm_network_security_group.private_nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_databricks_workspace" "this" {
  name                        = "${local.prefix}-workspace"
  resource_group_name         = var.azurerm_resource_group_name
  location                    = var.resource_group_location
  sku                         = "premium"
  managed_resource_group_name = "${local.prefix}-workspace-rg"
  tags                        = local.tags

  custom_parameters {
    virtual_network_id                                   = azurerm_virtual_network.example.id
    no_public_ip                                         = true
    public_subnet_name                                   = azurerm_subnet.public.name
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.nsga_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsga_private.id
  }
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}