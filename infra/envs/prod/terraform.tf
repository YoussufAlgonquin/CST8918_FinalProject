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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Fill in storage_account_name from infra/tf-backend outputs after that
  # stack is applied manually once. ARM_ACCESS_KEY via the environment.
  backend "azurerm" {
    resource_group_name  = "cst8918-final-project-group-6-tfstate"
    storage_account_name = "REPLACE_AFTER_TF_BACKEND_APPLY"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
