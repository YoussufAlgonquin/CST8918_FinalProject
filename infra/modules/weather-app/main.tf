resource "random_string" "acr_suffix" {
  count   = var.manage_acr ? 1 : 0
  length  = 6
  special = false
  upper   = false
}

# --- Azure Container Registry ---
# Only created when manage_acr = true (see variables.tf). Admin
# credentials are disabled on purpose: the AKS kubelet identity gets
# AcrPull via role assignment instead, so no ACR username/password
# ever needs to exist as a secret.
resource "azurerm_container_registry" "this" {
  count               = var.manage_acr ? 1 : 0
  name                = "acr${replace(var.prefix, "-", "")}${random_string.acr_suffix[0].result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

locals {
  acr_id           = var.manage_acr ? azurerm_container_registry.this[0].id : var.existing_acr_id
  acr_login_server = var.manage_acr ? azurerm_container_registry.this[0].login_server : var.existing_acr_login_server
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = local.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_kubelet_identity_object_id
  # principal_id must be the AKS cluster's KUBELET identity object ID
  # (not the control-plane identity) — that's the identity that
  # actually pulls images from ACR. The aks module should expose this
  # as an output, e.g. `kubelet_identity_object_id`.
}

# --- Azure Cache for Redis ---
resource "azurerm_redis_cache" "this" {
  name                = "redis-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity              = var.redis_capacity
  family                = var.redis_family
  sku_name              = var.redis_sku_name
  non_ssl_port_enabled  = false
  minimum_tls_version   = "1.2"
}

# --- Kubernetes provider ---
provider "kubernetes" {
  host                   = var.aks_host
  client_certificate     = base64decode(var.aks_client_certificate)
  client_key             = base64decode(var.aks_client_key)
  cluster_ca_certificate = base64decode(var.aks_cluster_ca_certificate)
}

# --- Namespace per environment, keeps test/prod objects separated in-cluster ---
resource "kubernetes_namespace" "this" {
  metadata {
    name = "weather-app-${var.environment}"
  }
}

# --- Secret: OpenWeather API key + Redis connection info ---
# Values come from Terraform variables (marked sensitive) that CI
# injects from GitHub Actions secrets via TF_VAR_*. Nothing here is
# ever written to a file that gets committed.
resource "kubernetes_secret" "weather_app" {
  metadata {
    name      = "weather-app-secrets"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    WEATHER_API_KEY = var.openweather_api_key
    REDIS_HOST      = azurerm_redis_cache.this.hostname
    REDIS_PORT      = azurerm_redis_cache.this.ssl_port
    REDIS_PASSWORD  = azurerm_redis_cache.this.primary_access_key
    REDIS_TLS       = "true"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "weather_app" {
  metadata {
    name      = "weather-app"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = { app = "weather-app" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "weather-app" }
    }

    template {
      metadata {
        labels = { app = "weather-app" }
      }

      spec {
        container {
          name  = "weather-app"
          image = "${local.acr_login_server}/${var.image_name}:${var.image_tag}"

          port {
            container_port = var.container_port
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.weather_app.metadata[0].name
            }
          }

          env {
            name  = "PORT"
            value = tostring(var.container_port)
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [azurerm_role_assignment.aks_acr_pull]
}

resource "kubernetes_service" "weather_app" {
  metadata {
    name      = "weather-app"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    selector = { app = "weather-app" }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
}
