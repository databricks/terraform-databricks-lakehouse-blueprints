variable "prefix" {}

variable "env" {}

variable "zone" {}

variable "gcp_auth_file" {}

variable "project_id" {}

variable "delegate_from" {
 description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
 type        = list(string)
}

variable google_project {
}

variable "var_project" {
        default = "project-name"
    }
variable "var_env" {
        default = "dev"
    }
variable "var_company" {
        default = "company-name"
    }
variable "uc1_private_subnet" {
        default = "10.26.1.0/24"
    }
variable "uc1_public_subnet" {
        default = "10.26.2.0/24"
    }
variable "ue1_private_subnet" {
        default = "10.26.3.0/24"
    }
variable "ue1_public_subnet" {
        default = "10.26.4.0/24"
    }

variable "region" {
  default = "us-east1"
}

locals {
 terraform_service_account = var.databricks_google_service_account
}

resource "google_service_account" "sa2" {
 account_id   = "${var.prefix}-sa2"
 display_name = "Service Account for Databricks Provisioning"
    project= var.google_project

}

output "service_account" {
 value       = google_service_account.sa2.email
 description = "Add this email as a user in the Databricks account console"
}

data "google_iam_policy" "this" {
 binding {
   role    = "roles/iam.serviceAccountTokenCreator"
   members = var.delegate_from
 }
}

resource "google_service_account_iam_policy" "impersonatable" {
 service_account_id = google_service_account.sa2.name
 policy_data        = data.google_iam_policy.this.policy_data
}

resource "google_project_iam_custom_role" "workspace_creator" {
 role_id = "${var.prefix}_workspace_creator"
 title   = "Databricks Workspace Creator"
 permissions = [
   "iam.serviceAccounts.getIamPolicy",
   "iam.serviceAccounts.setIamPolicy",
   "iam.roles.create",
   "iam.roles.delete",
   "iam.roles.get",
   "iam.roles.update",
   "resourcemanager.projects.get",
   "resourcemanager.projects.getIamPolicy",
   "resourcemanager.projects.setIamPolicy",
   "serviceusage.services.get",
   "serviceusage.services.list",
   "serviceusage.services.enable"

 ]
    project= var.google_project

}

data "google_client_config" "current" {}

output "custom_role_url" {
 value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${data.google_client_config.current.project}%3Croles%3C${google_project_iam_custom_role.workspace_creator.role_id}"
}

resource "google_project_iam_member" "sa2_can_create_workspaces" {
 role   = google_project_iam_custom_role.workspace_creator.id
 member = "serviceAccount:${google_service_account.sa2.email}"
  project= var.google_project
}
