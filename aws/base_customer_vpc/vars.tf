variable "databricks_account_id" {}
variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "vpc_id" {}
variable "region" {}
variable "security_group_id" {}

// this input variable is of array type
variable "subnet_ids" {
  type = list(string)
}

variable "workspace_vpce_service" {}
variable "relay_vpce_service" {}
variable "vpce_subnet_cidr" {}

variable "private_dns_enabled" { default = true}
variable "tags" { default = {}}

// these resources (bucket and IAM role) are assumed created using your AWS provider and the examples here https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/mws_storage_configurations and https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/mws_credentials, respectively.
variable "root_bucket_name" {}
variable "cross_account_arn" {}

locals {
  prefix = "private-link-ws"
}