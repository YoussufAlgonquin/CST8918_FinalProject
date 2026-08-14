variable "group_number" {
  description = "Your group number from Brightspace -- must match envs/prod so the remote state lookup below points at the right storage account"
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

# --- Remote state lookup config ---
# Same values as the backend block above (repeated here because
# `terraform_remote_state` needs its own explicit config -- it can't
# read the backend block of the calling module).
variable "backend_resource_group_name" {
  type = string
}

variable "backend_storage_account_name" {
  type = string
}
