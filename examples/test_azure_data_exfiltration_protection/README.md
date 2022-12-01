---
page_title: "Provisioning Azure Databricks Hub and Spoke Deployment as per Data Exfiltration Protection with Terraform"
---

# Provisioning Azure Databricks Hub and Spoke Deployment as per Data Exfiltration Protection with Terraform

[Reference documentation and blog](https://databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html)
This Terraform configuration is an implementation of the above blog post.
Note: the firewall rules deviate slightly in that outbound traffic from the firewall is allowed to Databricks resources instead of specifying Databricks worker subnets.
This is to simplify outbound routing in the event that multiple `spoke`s are desired.

This guide is provided as-is and you can use this guide as the basis for your custom Terraform module.

It uses the following variables in configurations:

## Required

- `project_name`: (Required) The name of the project associated with the infrastructure to be managed by Terraform
- `location`: (Required) The location for the resources in this module
- `databricks_workspace_name`: (Required) The name of the Azure Databricks Workspace to deploy in the spoke vnet
- `scc_relay_address_prefixes`: (Required) The IP address(es) of the Databricks SCC relay (see <https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#control-plane-nat-and-webapp-ip-addresses>)
- `privatelink_subnet_address_prefixes`: (Required) The address prefix(es) for the PrivateLink subnet
- `firewall_name`: (Required) The name of the Azure Firewall deployed in your hub Virtual Network
- `firewall_private_ip`: (Required) The hub firewall's private IP address
- `webapp_and_infra_routes`: (Required) Map of regional webapp and ext-infra CIDRs.
   Check <https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#ip-addresses> for more info
   Ex., for eastus:
   {
     "webapp1" : "40.70.58.221/32",
     "webapp2" : "20.42.4.209/32",
     "webapp3" : "20.42.4.211/32",
     "ext-infra" : "20.57.106.0/28"
   }

## Optional

- `hub_resource_group_name`: (Optional) The name of the existing Resource Group containing the hub Virtual Network
- `hub_vnet_name`: (Optional) The name of the existing hub Virtual Network
- `hub_vnet_address_space`: (Optional) The address space for the hub Virtual Network
- `spoke_resource_group_name`: (Optional) The name of the Resource Group to create
- `spoke_vnet_address_space`: (Optional) The address space for the spoke Virtual Network
- `private_subnet_address_prefixes`: (Optional) The address prefix(es) for the Databricks private subnet
- `public_subnet_address_prefixes`: (Optional) The address prefix(es) for the Databricks public subnet
- `firewall_subnet_address_prefixes`: (Optional) The address prefixes for the Azure firewall subnet
- `public_repos`: (Optional) List of public repository IP addresses to allow access to.
- `tags`: (Optional) Map of tags to attach to resources

## Provider initialization

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.13.0"
    }
  }
}

```
