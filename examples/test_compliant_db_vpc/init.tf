terraform {
  backend "s3" {
    bucket = "databricks-terraform-blueprints2"
    key    = "test_aws_base.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}