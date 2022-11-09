variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "spoke_vnet_address_space" {
  type        = string
  description = "(Optional) The address space for the spoke Virtual Network"
  default     = "10.2.1.0/24"
}

variable "databricks_workspace_name" {
  type        = string
  description = "(Required) The name of the Azure Databricks Workspace to deploy"
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "(Optional) The address prefix(es) for the Databricks private subnet"
  default     = ["10.2.1.128/26"]
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "(Optional) The address prefix(es) for the Databricks public subnet"
  default     = ["10.2.1.64/26"]
}

variable "scc_relay_address_prefixes" {
  type        = list(string)
  description = "(Required) The IP address(es) of the Databricks SCC relay (see https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#control-plane-nat-and-webapp-ip-addresses)"
}

variable "webapp_address_prefixes" {
  type        = list(string)
  description = "(Required) The IP address(es) of the Databricks regional webapp (see https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#control-plane-nat-and-webapp-ip-addresses)"
}

variable "extended_infrastructure_address_prefixes" {
  type        = list(string)
  description = "(Required) The IP address(es) of the Databricks regional extended infrastructure (see https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#control-plane-nat-and-webapp-ip-addresses)"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to attach to resources"
  default     = {}
}
