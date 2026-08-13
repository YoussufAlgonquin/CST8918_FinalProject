variable "resource_group_name" {
  description = "Name of the resource group, e.g. cst8918-final-project-group-6"
  type        = string
}

variable "location" {
  description = "Azure region for the network resources"
  type        = string
  default     = "canadacentral"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/14"]
}

variable "subnet_address_prefixes" {
  description = "Map of environment name to subnet CIDR"
  type        = map(string)
  default = {
    prod  = "10.0.0.0/16"
    test  = "10.1.0.0/16"
    dev   = "10.2.0.0/16"
    admin = "10.3.0.0/16"
  }
}
