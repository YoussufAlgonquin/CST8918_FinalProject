# AKS cluster module, parameterized per environment.
#
# Spec (see assignment):
#   test -> 1 node,               Standard_B2s, Kubernetes 1.32
#   prod -> autoscale 1-3 nodes,  Standard_B2s, Kubernetes 1.32
#
# TODO(owner): implement azurerm_kubernetes_cluster using the variables
# below (default_node_pool.enable_auto_scaling / min_count / max_count
# for prod, node_count for test).

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
