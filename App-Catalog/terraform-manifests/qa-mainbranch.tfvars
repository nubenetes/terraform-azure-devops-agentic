# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

#client_names_europe        = ["client1", "client2", "client3", "client4","client5"]
#client_names_unitedstates  = ["client1", "client2", "client3"]

dns_child_zone                    = "eng"  # This env is setup on eng.Enterprise.com dns_child_zone
azure_subscription_unitedstates   = "00000000-0000-0000-0000-000000000002"   # Enterprise DevTest Subscription
azure_subscription_europe         = "00000000-0000-0000-0000-000000000002"   # Enterprise DevTest Subscription
deploy_Europe                     = true
deploy_United_States              = false

# Enterprise Monitor Client (Prometheus exporter):
prometheus_exporter_docker_image            = "Enterprisecatalogcr.azurecr.io/monitor-client"
prometheus_exporter_docker_image_tag        = "1.0.1"

# Enterprise appanalysis aka omni-catalog:
app_docker_image                            = "Enterprisecatalogcr.azurecr.io/omni" #"Enterprisedevtest.azurecr.io/omni" # OMNI aka appanalysis or OMNI-Catalog
app_docker_image_tag                        = "3.0.2"

# AKS Computation:
# docker_enable_ci                            = true
# k8s_cluster_name                            = "aks-computation-devtest"
# k8s_resource_group                          = "rg_aks_computation_devtest"

# MongoDB Atlas:
oplog_size_mb                               = 3090 #"4672" # With default value of 990 mb we can get an alert with the message "Replication Oplog Window has gone below 1 hours"

# Prometheus Push Gateway (used by Monitor Client)
prometheus_push_gateway                    = "pushgateway-devtest.Enterprise.com"