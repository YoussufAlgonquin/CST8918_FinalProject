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
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  description = "Subnet ID from the network module for this environment (nodes get their IPs here)"
  type        = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

# --- Node pool sizing ---
# test: fixed 1 node -> enable_auto_scaling = false, node_count = 1
# prod: autoscaling 1-3 -> enable_auto_scaling = true, min_count = 1, max_count = 3
variable "enable_auto_scaling" {
  type    = bool
  default = false
}

variable "node_count" {
  description = "Fixed node count. Only used when enable_auto_scaling = false."
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Minimum nodes. Only used when enable_auto_scaling = true."
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum nodes. Only used when enable_auto_scaling = true."
  type        = number
  default     = 3
}
