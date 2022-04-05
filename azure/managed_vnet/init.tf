terraform {
  required_providers {
    azurerm = "~> 2.33"
    random  = "~> 2.2"
  }
}

provider "azurerm" {
  features {}
}

variable "region" {
  type    = string
  default = "westeurope"
}

variable "azurerm_resource_group_name" {
  type = string
  default = ""
}

variable "resource_group_location" {
  type = string
  default = "eastus2"
}

variable dbname {}