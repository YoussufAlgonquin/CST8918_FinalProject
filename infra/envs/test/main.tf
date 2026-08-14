# Reads the network and ACR that envs/prod created, instead of trying
# to create them again (there's only one shared VNet + ACR for the
# whole project). Run `terraform apply` in envs/prod BEFORE envs/test
# -- this data source will fail to resolve otherwise.
data "terraform_remote_state" "prod" {
  backend = "azurerm"

  config = {
    resource_group_name = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name        = "tfstate"
    key                    = "prod.tfstate"
  }
}

locals {
  prefix = "cst8918-final-project-group-${var.group_number}-test"
}

# --- AKS (test: fixed 1 node) ---
module "aks" {
  source = "../../modules/aks"

  prefix               = local.prefix
  environment           = "test"
  resource_group_name  = data.terraform_remote_state.prod.outputs.resource_group_name
  location              = var.location
  subnet_id             = data.terraform_remote_state.prod.outputs.subnet_ids["test"]
  enable_auto_scaling  = false
  node_count            = 1
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

# --- Weather app (test: attaches to prod's ACR, small Redis, 1 replica) ---
module "weather_app" {
  source = "../../modules/weather-app"

  prefix               = local.prefix
  environment           = "test"
  resource_group_name  = data.terraform_remote_state.prod.outputs.resource_group_name
  location              = var.location

  manage_acr                = false
  existing_acr_id           = data.terraform_remote_state.prod.outputs.acr_id
  existing_acr_login_server = data.terraform_remote_state.prod.outputs.acr_login_server

  aks_host                        = module.aks.host
  aks_client_certificate          = module.aks.client_certificate
  aks_client_key                  = module.aks.client_key
  aks_cluster_ca_certificate      = module.aks.cluster_ca_certificate
  aks_kubelet_identity_object_id  = module.aks.kubelet_identity_object_id

  redis_capacity = 0
  redis_sku_name = "Basic"

  image_tag             = var.image_tag
  replicas               = 1
  openweather_api_key   = var.openweather_api_key
}
