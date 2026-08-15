variable "group_number" {
  description = "Brightspace group number, used in resource names"
  type        = string
  default     = "6"

  validation {
    condition     = can(regex("^[0-9]+$", var.group_number))
    error_message = "group_number must be digits only (embedded in Azure resource names)."
  }
}

# Location is taken from test remote state (network VNet region), not a
# separate prod variable — AKS must live in the same region as its subnet.

variable "weather_api_key" {
  description = "OpenWeatherMap API key for the Remix weather app"
  type        = string
  sensitive   = true
  default     = ""
}

# Must match the values written into this root's backend "azurerm" block
# (and test's) after infra/tf-backend is applied.
variable "tf_state_resource_group_name" {
  description = "Resource group of the Terraform state storage account"
  type        = string
  default     = "cst8918-final-project-group-6-tfstate"
}

variable "tf_state_storage_account_name" {
  description = "Storage account used for the azurerm backend (from tf-backend output)"
  type        = string
  default     = "REPLACE_AFTER_TF_BACKEND_APPLY"
}

variable "tf_state_container_name" {
  description = "Blob container used for the azurerm backend"
  type        = string
  default     = "tfstate"
}
