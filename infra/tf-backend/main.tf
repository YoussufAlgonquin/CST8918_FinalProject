# Bootstraps the Azure Storage Account + container used as the Terraform
# remote state backend for every other Terraform root in this repo
# (infra/envs/test, infra/envs/prod).
#
# This is applied manually, once, by whoever owns backend setup - it cannot
# use a remote backend itself (chicken-and-egg problem), so it keeps local
# state. See docs/task-breakdown.md for the owner and status of this piece.
#
# TODO(owner): define the resource group, storage account, and blob
# container here, e.g.:
#   - azurerm_resource_group.tfstate
#   - azurerm_storage_account.tfstate
#   - azurerm_storage_container.tfstate

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
