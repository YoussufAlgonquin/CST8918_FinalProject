variable "prefix" {
  description = "Naming prefix, e.g. cst8918-final-project-group-12-test"
  type        = string
}

variable "environment" {
  description = "Environment name: test or prod"
  type        = string
  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "environment must be \"test\" or \"prod\"."
  }
}

variable "resource_group_name" {
  description = "Resource group to deploy Redis (and ACR, if manage_acr is true) into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

# --- ACR ---
# ACR should exist once per project, not once per environment. Set
# manage_acr = true in exactly ONE environment's root module (we
# recommend prod) and pass its outputs into the other environment via
# existing_acr_id / existing_acr_login_server.
variable "manage_acr" {
  description = "Whether this instance of the module should create the ACR"
  type        = bool
  default     = false
}

variable "existing_acr_id" {
  description = "ACR resource ID to attach to, when manage_acr = false"
  type        = string
  default     = null
}

variable "existing_acr_login_server" {
  description = "ACR login server, when manage_acr = false"
  type        = string
  default     = null
}

variable "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity, for AcrPull role assignment"
  type        = string
}

# --- Redis ---
variable "redis_capacity" {
  description = "Redis capacity (0-6 for Basic/Standard, 1-5 for Premium)"
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "Redis SKU family: C (Basic/Standard) or P (Premium)"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis SKU: Basic, Standard, or Premium"
  type        = string
  default     = "Basic"
}

# --- Application ---
variable "image_name" {
  type    = string
  default = "remix-weather-app"
}

variable "image_tag" {
  description = "Docker image tag to deploy, e.g. the commit SHA from CI"
  type        = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "replicas" {
  type    = number
  default = 1
}

variable "openweather_api_key" {
  description = "OpenWeather API key. Populate via TF_VAR_openweather_api_key from a GitHub Actions secret — never commit a value for this."
  type        = string
  sensitive   = true
}
