variable "group_number" {
  description = "Brightspace group number, used in the resource group name and (with a random suffix) the storage account name"
  type        = string
  default     = "6"

  validation {
    # Storage account names must be <=24 chars, lowercase alphanumeric:
    # "cst8918fp" (9) + group_number + a 6-char random suffix, so
    # group_number is capped at 9 chars here.
    condition     = can(regex("^[a-z0-9]{1,9}$", var.group_number))
    error_message = "group_number must be lowercase alphanumeric, 1-9 characters (it's embedded in the 24-char-max storage account name)."
  }
}

variable "location" {
  description = "Azure region for the Terraform state backend"
  type        = string
  default     = "canadacentral"
}
