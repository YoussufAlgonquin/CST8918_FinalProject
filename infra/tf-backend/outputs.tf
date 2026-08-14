# Whoever applies this module manually copies these three values into the
# `backend "azurerm" {}` blocks in infra/envs/test/terraform.tf and
# infra/envs/prod/terraform.tf (resource_group_name, storage_account_name,
# container_name), and sets ARM_ACCESS_KEY (a storage account access key,
# see the sensitive output below) as a GitHub Actions secret for CI.

output "resource_group_name" {
  description = "Resource group holding the Terraform state storage account"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account used for the azurerm backend"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container used for the azurerm backend (matches `tfstate` key in envs/*)"
  value       = azurerm_storage_container.tfstate.name
}

output "storage_account_access_key" {
  description = "Primary access key for the state storage account (set as ARM_ACCESS_KEY secret)"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}
