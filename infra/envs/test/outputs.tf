output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "service_ip" {
  value = module.weather_app.service_ip
}
