# Base network module: resource group, virtual network, and the 4
# environment subnets (prod / test / dev / admin).
#
# Spec (see assignment):
#   - resource group: cst8918-final-project-group-<N>
#   - vnet address space: 10.0.0.0/14
#   - subnets, by environment (2nd octet = environment):
#       prod  -> 10.0.0.0/16
#       test  -> 10.1.0.0/16
#       dev   -> 10.2.0.0/16
#       admin -> 10.3.0.0/16
#
# TODO(owner): implement azurerm_resource_group, azurerm_virtual_network,
# and azurerm_subnet (x4) using the variables below.

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
