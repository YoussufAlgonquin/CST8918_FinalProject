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

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

# One subnet per environment (prod/test/dev/admin), keyed off
# var.subnet_address_prefixes so infra/modules/aks and infra/modules/
# weather-app can look up the right subnet by environment name.
resource "azurerm_subnet" "this" {
  for_each             = var.subnet_address_prefixes
  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}
