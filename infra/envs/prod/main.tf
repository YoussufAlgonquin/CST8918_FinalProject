# Root module for the production environment. Wires together the network,
# aks, and weather-app modules for env = "prod".
#
# TODO(owner): call infra/modules/network, infra/modules/aks (autoscale
# 1-3 nodes), and infra/modules/weather-app (env = "prod") with the "prod"
# subnet (10.0.0.0/16).
