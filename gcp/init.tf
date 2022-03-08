terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.4.5"
    }
    aws = {
      source = "hashicorp/google"
      version = "4.8.0"
    }    
  }
}

provider "google" {
  project = var.project
  region = var.region
  zone = var.zone
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

