# Resources for the Remix Weather Application itself, parameterized per
# environment (test / prod). Consumes the AKS cluster from
# infra/modules/aks (kubelet identity for AcrPull) and deploys into it.
#
# The kubernetes provider is configured from the AKS module's kube_config
# in the root module (infra/envs/<env>/main.tf), not hardcoded here.
#
# ACR is created once (test) and reused by prod via create_acr = false so
# the build/push workflow can keep a single ACR_NAME secret.

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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

locals {
  acr_id           = var.create_acr ? azurerm_container_registry.this[0].id : var.acr_id
  acr_login_server = var.create_acr ? azurerm_container_registry.this[0].login_server : var.acr_login_server
  # Bootstrap image until the first CI build pushes weather-app:<sha>; the
  # deployment ignores subsequent image changes so app-deploy.yml can roll
  # out new tags without Terraform reverting them. Uses the unprivileged
  # nginx variant because it listens on 8080 by default, matching the real
  # app's containerPort/readinessProbe - plain nginx listens on 80 and
  # would never pass the readiness probe below.
  container_image = var.container_image != "" ? var.container_image : "nginxinc/nginx-unprivileged:1.25"
  app_labels = {
    app         = "weather-app"
    environment = var.environment
  }
}

resource "random_string" "redis_suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

#tfsec:ignore:azure-container-use-image-scanner Basic SKU has no Defender scanning; enough for the course project.
resource "azurerm_container_registry" "this" {
  count               = var.create_acr ? 1 : 0
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = local.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = var.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

# Basic C0 is the cheapest SKU; no VNet injection on Basic, so the app
# reaches Redis over the public endpoint with TLS + access key.
#tfsec:ignore:azure-redis-enable-in-transit-encryption minimum_tls_version is set; tfsec's check targets a different flag.
#tfsec:ignore:azure-redis-no-public-network-access Basic SKU does not support private endpoints.
resource "azurerm_redis_cache" "this" {
  name                 = "redis-cst8918-${var.environment}-${random_string.redis_suffix.result}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  capacity             = var.redis_capacity
  family               = var.redis_family
  sku_name             = var.redis_sku_name
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
  }
}

resource "kubernetes_secret" "weather_app" {
  metadata {
    name   = "weather-app"
    labels = local.app_labels
  }

  data = {
    WEATHER_API_KEY = var.weather_api_key
    REDIS_HOST      = azurerm_redis_cache.this.hostname
    REDIS_PORT      = tostring(azurerm_redis_cache.this.ssl_port)
    REDIS_PASSWORD  = azurerm_redis_cache.this.primary_access_key
    REDIS_TLS       = "true"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "weather_app" {
  metadata {
    name   = "weather-app"
    labels = local.app_labels
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "weather-app"
      }
    }

    template {
      metadata {
        labels = local.app_labels
      }

      spec {
        container {
          name  = "weather-app"
          image = local.container_image

          port {
            name           = "http"
            container_port = 8080
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.weather_app.metadata[0].name
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image,
    ]
  }

  depends_on = [
    azurerm_role_assignment.aks_acr_pull,
    kubernetes_secret.weather_app,
  ]
}

resource "kubernetes_service" "weather_app" {
  metadata {
    name   = "weather-app"
    labels = local.app_labels
  }

  spec {
    selector = {
      app = "weather-app"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.weather_app]
}
