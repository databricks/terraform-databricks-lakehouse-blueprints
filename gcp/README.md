---
page_title: "Provisioning Secure Databricks Workspaces on GCP with Terraform"
---

# How to Deploy a Lakehouse Blueprint using Best Practices and Industry Helper Libraries

This guide uses the following variables in configurations:

- `databricks_account_id`: The ID per Databricks GCP account used for accessing account management APIs. After the GCP account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_google_service_account`: Service account used for programattically interacting with cloud infrastructure. More documentation [here](https://cloud.google.com/iam/docs/service-accounts)
- `delegate_from` - The user principal can be allowed to impersonate a service account using this parameter. Set to a user principal who should impersonate a service account for purposes of account infrastructure provisioning and workspace setup.
- `google_credentials` - JSON parameter used for authenticating a service account
- `google_impersonate_service_account` - Service account email which is being impersonated in the flow mentioned above.
- `google_project` - Top level abstraction used to organized all GCP resources
- `prefix` - Prefix used to tag resources in this workflow
- `project_id` - Numeric ID for project
- `gcp_auth_file` - JSON keys for service account. DO NOT place this file in this project.
- `env` - Environment used to spin up infrastructure. This is merely a tag.
- `region` - Region in which infrastructure is spun up.

This guide is provided as-is and you can use this guide as the basis for your custom Terraform module.

To get started, this code walks you through the following high-level steps:
- Initialize the required providers
- Configure GCP objects
  - A VPC which satisfies the Databricks GCP networking [requirements](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/customer-managed-vpc.html#network-requirements-1)
  - A Cloud NAT which is used for routing egress to public internet
  - Private Subnets
- Workspace Creation

## Provider initialization

Initialize [provider with `mws` alias](https://www.terraform.io/language/providers/configuration#alias-multiple-provider-configurations) to set up account-level resources.

```hcl
provider "google" {
 project = var.google_project
 region  = var.region
 zone    = var.zone
}

terraform {
 required_providers {
   databricks = {
     source  = "databrickslabs/databricks"
   }
 }
}


```
