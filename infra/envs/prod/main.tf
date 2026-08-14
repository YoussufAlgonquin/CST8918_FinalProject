locals {
  resource_group_name = "cst8918-final-project-group-${var.group_number}"
  prefix               = "cst8918-final-project-group-${var.group_number}-prod"
}

# --- Network ---
# prod owns the network module apply. It's ONE shared VNet with 4
# subnets (prod/test/dev/admin) per the assignment spec -- applying it
# a second time from envs/test would try to create a duplicate
# resource group/VNet and fail. test reads this module's outputs via
# terraform_remote_state instead (see infra/envs/test/main.tf).
module "network" {
  source = "../../modules/network"

  resource_group_name = local.resource_group_name
  location             = var.location
}

# --- AKS (prod: autoscaling 1-3 nodes) ---
module "aks" {
  source = "../../modules/aks"

  prefix               = local.prefix
  environment           = "prod"
  resource_group_name  = module.network.resource_group_name
  location              = var.location
  subnet_id             = module.network.subnet_ids["prod"]
  enable_auto_scaling  = true
  min_count             = 1
  max_count             = 3
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

# --- Weather app (prod: creates the shared ACR + prod Redis/deployment) ---
module "weather_app" {
  source = "../../modules/weather-app"

  prefix               = local.prefix
  environment           = "prod"
  resource_group_name  = module.network.resource_group_name
  location              = var.location

  manage_acr = true # prod owns the one shared ACR for the project

  aks_host                        = module.aks.host
  aks_client_certificate          = module.aks.client_certificate
  aks_client_key                  = module.aks.client_key
  aks_cluster_ca_certificate      = module.aks.cluster_ca_certificate
  aks_kubelet_identity_object_id  = module.aks.kubelet_identity_object_id

  redis_capacity = 1
  redis_sku_name = "Standard"

  image_tag             = var.image_tag
  replicas               = 2
  openweather_api_key   = var.openweather_api_key
}
