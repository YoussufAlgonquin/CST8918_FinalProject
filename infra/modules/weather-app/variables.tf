variable "environment" {
  description = "test or prod"
  type        = string

  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "environment must be \"test\" or \"prod\"."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "acr_name" {
  description = "Globally unique ACR name (alphanumeric only). Required when create_acr is true."
  type        = string
  default     = ""
}

variable "create_acr" {
  description = "Create an ACR in this module. Set false in prod and pass acr_id / acr_login_server from test."
  type        = bool
  default     = true
}

variable "acr_id" {
  description = "Existing ACR resource ID (when create_acr = false)"
  type        = string
  default     = null
}

variable "acr_login_server" {
  description = "Existing ACR login server (when create_acr = false)"
  type        = string
  default     = null
}

variable "kubelet_identity_object_id" {
  description = "AKS kubelet identity object ID, granted AcrPull on the ACR"
  type        = string
}

variable "redis_sku_name" {
  type    = string
  default = "Basic"
}

variable "redis_family" {
  type    = string
  default = "C"
}

variable "redis_capacity" {
  type    = number
  default = 0
}

variable "container_image" {
  description = "Full image ref, e.g. <acr>.azurecr.io/weather-app:<sha>. Empty uses a temporary nginx image until CI pushes the app."
  type        = string
  default     = ""
}

variable "weather_api_key" {
  description = "OpenWeatherMap API key injected into the weather-app secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "app_replicas" {
  type    = number
  default = 1
}
