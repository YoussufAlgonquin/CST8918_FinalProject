# Root module for the production environment.
#
# Does NOT recreate the shared network or ACR — those live in the test
# root module's state (single VNet with prod/test/dev/admin subnets, one
# registry for both environments). Apply test before prod.

data "terraform_remote_state" "test" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tf_state_resource_group_name
    storage_account_name = var.tf_state_storage_account_name
    container_name       = var.tf_state_container_name
    key                  = "test.terraform.tfstate"
  }
}

module "aks" {
  source = "../../modules/aks"

  cluster_name        = "cst8918-g${var.group_number}-prod-aks"
  resource_group_name = data.terraform_remote_state.test.outputs.resource_group_name
  location            = var.location
  subnet_id           = data.terraform_remote_state.test.outputs.subnet_ids["prod"]
  kubernetes_version  = "1.32"
  vm_size             = "Standard_B2s"
  enable_auto_scaling = true
  min_node_count      = 1
  max_node_count      = 3
}

provider "kubernetes" {
  host                   = module.aks.kube_config[0].host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

module "weather_app" {
  source = "../../modules/weather-app"

  environment                = "prod"
  resource_group_name        = data.terraform_remote_state.test.outputs.resource_group_name
  location                   = var.location
  create_acr                 = false
  acr_id                     = data.terraform_remote_state.test.outputs.acr_id
  acr_login_server           = data.terraform_remote_state.test.outputs.acr_login_server
  kubelet_identity_object_id = module.aks.kubelet_identity_object_id
  weather_api_key            = var.weather_api_key
  app_replicas               = 2
}

output "resource_group_name" {
  value = data.terraform_remote_state.test.outputs.resource_group_name
}

output "aks_cluster_name" {
  value = "cst8918-g${var.group_number}-prod-aks"
}

output "acr_login_server" {
  value = data.terraform_remote_state.test.outputs.acr_login_server
}

output "redis_hostname" {
  value = module.weather_app.redis_hostname
}

output "weather_app_service_ip" {
  value = module.weather_app.service_ip
}
