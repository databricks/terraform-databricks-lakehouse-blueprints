variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group to be created"
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "workspaces_to_associate" {
  type        = list(string)
  description = "(Optional) List of Databricks Workspace IDs to associate with Unity Catalog"
  default     = []
}

variable "databricks_resource_id" {}

