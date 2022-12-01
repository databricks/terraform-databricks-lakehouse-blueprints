---
page_title: "Create Cloud Resources for Unity Catalog, Assign Metastores, and Create Sample Catalog"
---

# Create Cloud Resources for Unity Catalog, Assign Metastores, and Create Sample Catalog

This module uses the following input variables. Please all variables here in a terraform.tfvars file (outside the github project) and reference it using `terraform apply -var-file="<location for tfvars file>/terraform.tfvars"`.

## Input Variables

- `databricks_account_id`: The ID per Databricks AWS account used for accessing account management APIs. After the AWS E2 account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_account_username`: E2 user account email address
- `databricks_account_password` - E2 account password
- `crossaccount_role_name` - Cross-account role name used for Databricks deployment
- `databricks_workspace_url` - Workspace URL
- `region` - region in which all AWS resources are deployed
- `workspaces_to_associate` - List of all numeric workspace IDs which should be associated to the created UC metastore
- `databricks_users` - List of all Databricks users which should be provisioned as part of the quickstart. This is mostly instructive and the best practice should be to use SCIM to sync users to the Databricks workspace - terraform can be used for the assignment (assuming users already exist)
- `databricks_metastore_admins` - List of all metastore admins to be added to the Databricks group
- `unity_admin_group` - Name of the group to be used as the admins for metastore, catalog, schema, and databases. This should be restricted to a small group of users with to administrate UC APIs.

```hcl
module "aws_uc" {
  source = "databricks/aws_uc/"
  
  databricks_account_id = # see description above
  databricks_account_username = # see description above
  databricks_account_password = # see description above
  crossaccount_role_name = # see description above
  databricks_workspace_url = # see description above
  region = # see description above
  databricks_users = # see description above
  databricks_metastore_admins = # see description above
  unity_admin_group = # see description above
  
}
```

## Provider initialization

Initialize with aws and databricks providers.

```hcl
terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints"
    key    = "test_aws_fs_lakehouse.tfstate"
    region = "us-east-1"
    profile = "default"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.6.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.35.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}
```
