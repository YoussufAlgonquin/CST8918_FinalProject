# Bootstraps the Azure Storage Account + container used as the Terraform
# remote state backend for every other Terraform root in this repo
# (infra/envs/test, infra/envs/prod).
#
# This is applied manually, once, by whoever owns backend setup - it cannot
# use a remote backend itself (chicken-and-egg problem), so it keeps local
# state. See docs/task-breakdown.md for the owner and status of this piece.

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "cst8918-final-project-group-${var.group_number}-tfstate"
  location = var.location
}

# Storage account names must be globally unique, lowercase alphanumeric,
# 3-24 chars - the random suffix avoids collisions with other groups/teams
# using the same naming pattern.
resource "random_string" "storage_account_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "cst8918fp${var.group_number}${random_string.storage_account_suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
