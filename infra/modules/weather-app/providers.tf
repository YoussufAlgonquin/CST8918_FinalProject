terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# The kubernetes provider is configured from the AKS module's outputs,
# so this module can be applied right after the aks module without any
# extra `az aks get-credentials` step. Configure it in the ROOT module
# (infra/envs/test or infra/envs/prod) like this, then pass the module
# block as usual:
#
# provider "kubernetes" {
#   host                   = module.aks.host
#   client_certificate     = base64decode(module.aks.client_certificate)
#   client_key             = base64decode(module.aks.client_key)
#   cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
# }
