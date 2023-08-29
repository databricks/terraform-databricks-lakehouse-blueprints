variable "client_id" {
  type = string
}

variable "workspace_host" {
  type = string
}

variable "client_secret" {
  type = string
}

provider "databricks" {
  host          = var.workspace_host
  client_id     = var.client_id
  client_secret = var.client_secret
}
