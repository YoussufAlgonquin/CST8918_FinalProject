variable "group_number" {
  description = "Brightspace group number, used in the resource group name"
  type        = string
  default     = "6"

  validation {
    condition     = can(regex("^[0-9]+$", var.group_number))
    error_message = "group_number must be digits only (embedded in Azure resource names)."
  }
}

variable "location" {
  description = "Azure region for test-environment resources"
  type        = string
  default     = "canadacentral"
}

variable "acr_name" {
  description = "Globally unique ACR name (5-50 lowercase alphanumeric). Shared with prod."
  type        = string
  # Override via TF_VAR_acr_name or a local *.tfvars (gitignored) if this
  # default is taken; Azure requires global uniqueness.
  default = "cst8918g6weather"
}

variable "weather_api_key" {
  description = "OpenWeatherMap API key for the Remix weather app"
  type        = string
  sensitive   = true
  default     = ""
}
