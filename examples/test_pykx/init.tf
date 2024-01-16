terraform {
  backend "s3" {
    bucket = "blueprints-pykx-rp"
    key    = "test-pykx.tfstate"
    region = "us-east-1"
  }
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.54.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
