variable "group_number" {
  description = "Your group number from Brightspace"
  type        = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "image_tag" {
  description = "Docker image tag to deploy (commit SHA from CI)"
  type        = string
}

variable "openweather_api_key" {
  type      = string
  sensitive = true
}
