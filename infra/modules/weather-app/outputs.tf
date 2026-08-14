output "acr_id" {
  value = local.acr_id
}

output "acr_login_server" {
  value = local.acr_login_server
}

output "redis_hostname" {
  value = azurerm_redis_cache.this.hostname
}

output "redis_ssl_port" {
  value = azurerm_redis_cache.this.ssl_port
}

output "service_ip" {
  description = "Public LoadBalancer IP for the weather app (may be empty until Azure assigns one)"
  value       = try(kubernetes_service.weather_app.status[0].load_balancer[0].ingress[0].ip, null)
}

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}
