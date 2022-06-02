provider "google" {
 project = var.google_project
 region  = "us-east1"
 zone    = "us-east1-b"
}

provider "databricks" {
 alias                  = "accounts"
 host                   = "https://accounts.gcp.databricks.com"
 google_service_account = var.databricks_google_service_account
}
