output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

# --- Everything below feeds directly into the weather-app module ---
# and into the `provider "kubernetes" {}` block in the root module, e.g.:
#
#   provider "kubernetes" {
#     host                   = module.aks.host
#     client_certificate     = base64decode(module.aks.client_certificate)
#     client_key             = base64decode(module.aks.client_key)
#     cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
#   }
#
# then pass the same four values as vars into module "weather_app" too,
# since that module configures its own kubernetes provider internally
# (see infra/modules/weather-app/main.tf).

output "host" {
  value     = azurerm_kubernetes_cluster.this.kube_config.0.host
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.this.kube_config.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate
  sensitive = true
}

# The AKS-managed identity that actually pulls images -- this is what
# the weather-app module's AcrPull role assignment targets. NOT the
# cluster's own SystemAssigned identity (identity[0].principal_id) --
# that one manages Azure resources on the cluster's behalf, but image
# pulls go through the separate kubelet identity.
output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity.0.object_id
}
