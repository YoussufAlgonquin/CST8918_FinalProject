output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster, used to configure the kubernetes provider in infra/modules/weather-app"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the cluster's kubelet identity, used to grant AcrPull on the ACR"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
