variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "subnet_id" {
  description = "Subnet the AKS node pool will be attached to"
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

variable "enable_auto_scaling" {
  description = "true for prod (1-3 nodes), false for test (fixed 1 node)"
  type        = bool
  default     = false
}

variable "node_count" {
  description = "Fixed node count when enable_auto_scaling = false (test)"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum nodes when enable_auto_scaling = true (prod)"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes when enable_auto_scaling = true (prod)"
  type        = number
  default     = 3
}
