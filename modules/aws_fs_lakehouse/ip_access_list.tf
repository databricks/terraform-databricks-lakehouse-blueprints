resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists" : true
  }
}

resource "databricks_ip_access_list" "allowed-list" {
  label        = "allow_in"
  list_type    = "ALLOW"
  ip_addresses = var.allow_ip_list
  depends_on   = [databricks_workspace_conf.this]
}