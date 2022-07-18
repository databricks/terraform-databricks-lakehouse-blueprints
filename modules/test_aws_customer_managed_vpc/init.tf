terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints"
<<<<<<< HEAD
    key    = "test_aws_customer_managed_vpc.tfstate"
    region = "us-east-1"
    profile = "aws-field-eng_databricks-power-user"
=======
    key = "test_aws_customer_managed_vpc.tfstate"
    region = "us-east-1"
>>>>>>> d7d0625 (add new files for module)
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
<<<<<<< HEAD
      version = "~>1.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.22.0"
=======
      version = "0.5.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.49.0"
>>>>>>> d7d0625 (add new files for module)
    }
  }
}

provider "aws" {
  region = var.region
<<<<<<< HEAD
  profile = "aws-field-eng_databricks-power-user"
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
=======
}

// initialize provider in "MWS" mode for provisioning workspace with AWS PrivateLink
provider "databricks" {
  alias    = "mws"
>>>>>>> d7d0625 (add new files for module)
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

