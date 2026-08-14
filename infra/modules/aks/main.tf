# AKS cluster module, parameterized per environment.
#
# Spec (see assignment):
#   test -> 1 node,               Standard_B2s, Kubernetes 1.32
#   prod -> autoscale 1-3 nodes,  Standard_B2s, Kubernetes 1.32

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# No authorized_ip_ranges: this is a small course-project cluster with no
# fixed egress IP to allowlist. Revisit if this ever handles real data.
#tfsec:ignore:azure-container-limit-authorized-ips
# Container insights (oms_agent) needs a Log Analytics Workspace, which is
# out of scope for this module - add it if observability becomes a
# requirement.
#tfsec:ignore:azure-container-logging
resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.cluster_name
  kubernetes_version                = var.kubernetes_version
  role_based_access_control_enabled = true

  default_node_pool {
    name                 = "default"
    vm_size              = var.vm_size
    vnet_subnet_id       = var.subnet_id
    auto_scaling_enabled = var.enable_auto_scaling
    node_count           = var.enable_auto_scaling ? null : var.node_count
    min_count            = var.enable_auto_scaling ? var.min_node_count : null
    max_count            = var.enable_auto_scaling ? var.max_node_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }
}
