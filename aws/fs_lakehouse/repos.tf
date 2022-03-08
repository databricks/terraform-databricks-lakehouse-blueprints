terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.4.5"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.49.0"
    }    
  }
}

provider "aws" {
  region = local.region
}


provider "databricks" {
}


resource "databricks_repo" "sol_accelerators" {
  url = "https://github.com/databrickslabs/tempo.git"
}

resource "databricks_repo" uc_setup {
  url = "https://github.com/databricks/unity-catalog-setup.git"
}

resource "databricks_repo" cyber {
  url = "https://github.com/databrickslabs/splunk-integration.git"
}