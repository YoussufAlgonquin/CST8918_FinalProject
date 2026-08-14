output "acr_id" {
  description = "ACR resource ID (created here or passed through when create_acr = false)"
  value       = local.acr_id
}

output "acr_name" {
  description = "ACR name (null when create_acr = false and only an ID/login server were passed)"
  value       = var.create_acr ? azurerm_container_registry.this[0].name : null
}

output "acr_login_server" {
  description = "ACR login server hostname"
  value       = local.acr_login_server
}

output "redis_hostname" {
  description = "Azure Cache for Redis hostname"
  value       = azurerm_redis_cache.this.hostname
}

output "redis_ssl_port" {
  description = "Azure Cache for Redis SSL port"
  value       = azurerm_redis_cache.this.ssl_port
}

output "service_name" {
  description = "Kubernetes Service name for the weather app"
  value       = kubernetes_service.weather_app.metadata[0].name
}

output "service_ip" {
  description = "LoadBalancer external IP (empty until Azure assigns one)"
  value = try(
    kubernetes_service.weather_app.status[0].load_balancer[0].ingress[0].ip,
    null
  )
}
