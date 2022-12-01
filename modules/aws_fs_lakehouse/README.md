---
page_title: "Create Resources in Existing Databricks Workspace and Configure Storage, Jobs, IP Access Lists, and Library Installation"
---

# Create Resources in Existing Databricks Workspace and Configure Storage, Jobs, IP Access Lists, and Library Installation

This module uses the following input variables. Please all variables here in a terraform.tfvars file (outside the github project) and reference it using `terraform apply -var-file="<location for tfvars file>/terraform.tfvars"`.

## Input Variables

- `databricks_account_id`: The ID per Databricks AWS account used for accessing account management APIs. After the AWS E2 account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_account_username`: E2 user account email address
- `databricks_account_password` - E2 account password
- `crossaccount_role_name` - Cross-account role name used for Databricks deployment
- `workspace_url` - Workspace URL
- `allow_ip_list` - List of allowable IPs to access Databricks workspace UI login and REST API
- `use_ip_access_list`- Boolean to indicate whether to set an IP access list

```hcl
module "aws_fs_lakehouse" {
  source = "databricks/aws_fs_lakehouse/"
  
  databricks_account_id = # see description above
  databricks_account_username = # see description above
  databricks_account_password = # see description above
  crossaccount_role_name = # see description above
  workspace_url = # see description above
  allow_ip_list = # see description above
  use_ip_access_list = # see description above
  
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
