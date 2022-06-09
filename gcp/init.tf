provider "google" {
 project = var.google_project
 region  = "us-east1"
 zone    = "us-east1-b"
}

provider "google" {
 alias = "impersonation"
 scopes = [
   "https://www.googleapis.com/auth/cloud-platform",
   "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google" {
 alias = "service_perimeter_sa"
 project         = var.google_project
 access_token    = data.google_service_account_access_token.default.access_token
 request_timeout = "60s"
}

data "google_service_account_access_token" "default" {
 provider               = google.impersonation
 target_service_account = local.terraform_service_account
 scopes                 = ["userinfo-email", "cloud-platform"]
 lifetime               = "1200s"
 depends_on = [google_project_iam_member.sa2_can_create_workspaces]
}


provider "databricks" {
 alias                  = "accounts"
 host                   = "https://accounts.gcp.databricks.com"
 google_service_account = var.databricks_google_service_account
}
