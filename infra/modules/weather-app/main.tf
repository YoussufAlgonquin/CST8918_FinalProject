# Resources for the Remix Weather Application itself, parameterized per
# environment (test / prod). Consumes the AKS cluster from
# infra/modules/aks and deploys into it.
#
# TODO(owner): implement
#   - azurerm_container_registry (ACR) - shared or per-env, team's choice
#   - azurerm_redis_cache (Azure Cache for Redis) - one per environment
#   - kubernetes_deployment (Remix app image + Redis connection env vars)
#   - kubernetes_service (expose the deployment)
#
# The kubernetes provider should be configured from the AKS module's
# kube_config output in the root module (infra/envs/<env>/main.tf), not
# hardcoded here.

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}
