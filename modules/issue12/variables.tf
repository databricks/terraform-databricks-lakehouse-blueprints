variable "project_id" {
  type        = string
  description = "Project ID for the Workspace"
}
variable "subscription_id" {
  type        = string
  description = "Azure subscription id for terraform auth"
}

variable "client_id" {
  type        = string
  description = "Azure service principal client id for terraform auth"
}

variable "client_secret" {
  type        = string
  description = "Azure service principal client secret for terraform auth"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure service principal tenant id for terraform auth"
}

variable "workspace_name" {
  type        = string
  description = "Name of Databricks workspace"
}

variable "vnet_name" {
  type        = string
  description = "Name of existing virtual network into which Databricks will be deployed"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet"
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
}

variable "public_subnet_address_prefix" {
  type        = list(string)
  description = "CIDR prefix of the public subnet"
}

variable "private_subnet_address_prefix" {
  type        = list(string)
  description = "CIDR prefix of the public subnet"
}

variable "storage_account_name" {
  type        = string
  description = "VPCX storage account name (to be mounted for cluster logs)"
}

variable "business_unit" {
  type        = string
  description = "Name of the business unit that will use the Databricks Workspace. Used in tagging cluster policies"
}

variable "routes" {
  type        = map(any)
  description = <<EOT
  (Required) Map of route table entries.
  For example:
  {
    "databricks-control-plane-route" = { address_prefix = "52.239.169.196/32", next_hop_type = "VnetLocal" },
    "databricks-artifact-blob-route" = { address_prefix = "52.239.169.164/32", next_hop_type = "Internet" }
  }
  EOT
}

variable "firewall_routes" {
  type        = map(any)
  description = "(Required) Map of firewall route table entries. (Defaults are for EastUS)"
  default = {
    "default-route" = "0.0.0.0/0",
    "adb-webapp1"   = "40.70.58.221/32",
    "adb-webapp2"   = "20.42.4.209/32",
    "adb-webapp3"   = "20.42.4.211/32",
  }
}

variable "firewall_ip" {
  type        = string
  description = "IP for hub vnet firewall"
  default     = "10.49.0.4"
}

variable "notification_emails" {
  type        = list(string)
  description = "Email addresses to notify in case of backup job failure"
}

variable "kv_name" {
  type        = string
  description = "Name of Azure Key Vault"
}

variable "secret_key" {
  type        = string
  description = "Name of the secret containing the service principal secret"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to Databricks workspace"
  default     = {}
}
