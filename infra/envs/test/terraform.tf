terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Same storage account as prod, different state key.
  backend "azurerm" {
    resource_group_name = "" # <- tf-backend output: backend_resource_group_name
    storage_account_name = "" # <- tf-backend output: backend_storage_account_name
    container_name        = "tfstate"
    key                    = "test.tfstate"
  }
}

provider "azurerm" {
  features {}
}
