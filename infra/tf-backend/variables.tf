variable "group_number" {
  description = "Brightspace group number, used in the resource group name"
  type        = string
  default     = "6"
}

variable "location" {
  description = "Azure region for the Terraform state backend"
  type        = string
  default     = "canadacentral"
}
