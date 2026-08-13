variable "environment" {
  description = "test or prod"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "acr_name" {
  description = "Globally unique ACR name (alphanumeric only)"
  type        = string
}

variable "redis_sku_name" {
  type    = string
  default = "Basic"
}

variable "container_image" {
  description = "Full image ref, e.g. <acr>.azurecr.io/weather-app:<sha>"
  type        = string
  default     = ""
}
