# Consumed by infra/envs/test via `data "terraform_remote_state" "prod"`.
# If you rename or remove any of these, update envs/test/main.tf too.

output "resource_group_name" {
  value = module.network.resource_group_name
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "acr_id" {
  value = module.weather_app.acr_id
}

output "acr_login_server" {
  value = module.weather_app.acr_login_server
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "service_ip" {
  value = module.weather_app.service_ip
}
