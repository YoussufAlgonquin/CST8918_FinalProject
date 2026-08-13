# Root module for the test environment. Wires together the network, aks,
# and weather-app modules for env = "test".
#
# TODO(owner): call infra/modules/network, infra/modules/aks (1 fixed
# node), and infra/modules/weather-app (env = "test") with the "test"
# subnet (10.1.0.0/16).
