# Root module for the test environment.
#
# Owns the shared network (one VNet / four subnets for the whole project)
# plus the test AKS cluster, shared ACR, test Redis, and k8s workload.
# Prod reads network + ACR outputs from this state via terraform_remote_state.
#
# First-time apply (empty subscription / no cluster yet): the kubernetes
# provider below depends on module.aks.kube_config, which is only known
# after the cluster exists. Run a two-step apply:
#   terraform apply -target=module.network -target=module.aks
#   terraform apply
# Subsequent applies are a single `terraform apply`.

locals {
  aks_cluster_name = "cst8918-g${var.group_number}-test-aks"
}

module "network" {
  source = "../../modules/network"

  resource_group_name = "cst8918-final-project-group-${var.group_number}"
  location            = var.location
}

module "aks" {
  source = "../../modules/aks"

  cluster_name        = local.aks_cluster_name
  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  subnet_id           = module.network.subnet_ids["test"]
  kubernetes_version  = "1.32"
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false
  node_count          = 1
}

provider "kubernetes" {
  host                   = module.aks.kube_config[0].host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

module "weather_app" {
  source = "../../modules/weather-app"

  environment                = "test"
  resource_group_name        = module.network.resource_group_name
  location                   = module.network.location
  create_acr                 = true
  acr_name                   = var.acr_name
  kubelet_identity_object_id = module.aks.kubelet_identity_object_id
  weather_api_key            = var.weather_api_key
  app_replicas               = 1
}

output "resource_group_name" {
  value = module.network.resource_group_name
}

output "location" {
  value = module.network.location
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "acr_id" {
  value = module.weather_app.acr_id
}

output "acr_name" {
  value = module.weather_app.acr_name
}

output "acr_login_server" {
  value = module.weather_app.acr_login_server
}

output "redis_hostname" {
  value = module.weather_app.redis_hostname
}

output "weather_app_service_ip" {
  value = module.weather_app.service_ip
}
