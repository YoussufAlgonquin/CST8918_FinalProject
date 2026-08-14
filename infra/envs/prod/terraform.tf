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

  # Fill these in from `infra/tf-backend`'s outputs after it has been
  # applied manually (once) by whoever owns backend setup. See
  # docs/task-breakdown.md item #1. Do NOT put the storage account
  # access key here -- that goes in the ARM_ACCESS_KEY CI secret / your
  # local `az login` session, never in this file.
  backend "azurerm" {
    resource_group_name = "" # <- tf-backend output: backend_resource_group_name
    storage_account_name = "" # <- tf-backend output: backend_storage_account_name
    container_name        = "tfstate"
    key                    = "prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}
