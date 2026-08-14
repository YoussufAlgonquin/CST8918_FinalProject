# One AKS cluster per environment. Called twice from the root modules:
#   infra/envs/test -> enable_auto_scaling = false, node_count = 1
#   infra/envs/prod -> enable_auto_scaling = true,  min_count = 1, max_count = 3
# Both use vm_size = Standard_B2s and kubernetes_version = 1.32 (module
# defaults), per the assignment spec.

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.prefix}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    vm_size             = var.vm_size
    vnet_subnet_id      = var.subnet_id
    auto_scaling_enabled = var.enable_auto_scaling

    # Only one of (node_count) or (min_count/max_count) actually takes
    # effect depending on enable_auto_scaling, but azurerm accepts
    # null for the unused side, so this stays a single resource block
    # rather than two near-duplicate resources.
    node_count = var.enable_auto_scaling ? null : var.node_count
    min_count  = var.enable_auto_scaling ? var.min_count : null
    max_count  = var.enable_auto_scaling ? var.max_count : null
  }

  # System-assigned identity for the cluster itself. AKS also creates
  # a separate kubelet identity automatically -- that's the one that
  # needs AcrPull on the registry (see the kubelet_identity_object_id
  # output below, consumed by the weather-app module).
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = {
    environment = var.environment
    project     = "cst8918-final-project"
  }
}
