---
page_title: "Create an AWS Databricks-compatible VPC using Terraform"
---

# Create an AWS Databricks-compatible VPC using Terraform

This module uses the following input variables. Please all variables here in a terraform.tfvars file (outside the github project) and reference it using `terraform apply -var-file="<location for tfvars file>/terraform.tfvars"`.

## Input Variables

- `databricks_account_id`: The ID per Databricks AWS account used for accessing account management APIs. After the AWS E2 account is created, this is available after logging into [https://accounts.cloud.databricks.com](https://accounts.cloud.databricks.com).
- `databricks_account_username`: E2 user account email address
- `databricks_account_password` - E2 account password
- `tags` - Tags for infrastructure inside AWS VPC
- `cidr_block` - CIDR blockfor VPC of size /16 to house subnets in ranges in between /17 through /26
- `region` - AWS region for VPC

## Output Variables

- `security_group` - Security group ID used for workspace creation and network
- `vpc_id` - VPC identifier in AW
- `subnets` - Private subnet IDs used for workspace creation
- `cross_account_role_arn` - Cross-account role ARN for deploying Databricks workspace
- `root_bucket` - Name of S3 bucket used as Databricks root bucket

```hcl
module "aws_base" {
  source = "databricks/aws_base/"
  
  databricks_account_id = # see description above
  databricks_account_username = # see description above
  databricks_account_password = # see description above
  tags = # see description above
  cidr_block = # see description above
  region = # see description above
  
}
```

## Provider initialization

Initialize with aws and databricks providers.

```hcl
terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints"
    key    = "test_compliant_db_vpc.tfstate"
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
