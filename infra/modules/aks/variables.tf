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
  description = "Assignment spec says 1.32, but Azure has since moved that version to LTS-only (paid Premium tier) - 1.34 is the oldest version still on the free standard support plan as of this apply."
  type        = string
  default     = "1.34"
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

# Must not overlap the shared VNet address space (10.0.0.0/14).
variable "service_cidr" {
  description = "Kubernetes service CIDR (outside the VNet)"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP within service_cidr"
  type        = string
  default     = "172.16.0.10"
}

variable "pod_cidr" {
  description = "kubenet pod CIDR (outside the VNet)"
  type        = string
  default     = "172.17.0.0/16"
}
