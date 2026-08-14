output "resource_group_name" {
  description = "Name of the resource group holding the network (and, by convention, the rest of the env's resources)"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Map of environment name (prod/test/dev/admin) to subnet ID"
  value       = { for env, subnet in azurerm_subnet.this : env => subnet.id }
}
