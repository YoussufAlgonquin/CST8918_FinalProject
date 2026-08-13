terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }

  # TODO(owner): fill in once infra/tf-backend is applied. Storage account
  # name/container are looked up from the backend outputs; access key is
  # supplied via ARM_ACCESS_KEY in CI, not committed here.
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
