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

  validation {
    condition     = var.create_acr ? length(var.acr_name) > 0 : true
    error_message = "acr_name is required when create_acr = true."
  }
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

  validation {
    condition     = var.create_acr ? true : var.acr_id != null
    error_message = "acr_id is required when create_acr = false."
  }
}

variable "acr_login_server" {
  description = "Existing ACR login server (when create_acr = false)"
  type        = string
  default     = null

  validation {
    condition     = var.create_acr ? true : var.acr_login_server != null
    error_message = "acr_login_server is required when create_acr = false."
  }
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

variable "service_type" {
  description = "Defaults to LoadBalancer. Azure for Students caps public IPs per region (3 in this subscription); with both AKS clusters' own outbound IP plus one LoadBalancer service already at the limit, one environment may need ClusterIP instead."
  type        = string
  default     = "LoadBalancer"

  validation {
    condition     = contains(["LoadBalancer", "ClusterIP"], var.service_type)
    error_message = "service_type must be \"LoadBalancer\" or \"ClusterIP\"."
  }
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
