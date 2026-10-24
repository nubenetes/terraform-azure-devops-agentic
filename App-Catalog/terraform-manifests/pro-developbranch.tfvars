# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

#client_names_europe        = ["client1", "client2", "client3", "client4","client5"]
#client_names_unitedstates  = ["client1", "client2", "client3"]

dns_child_zone        = "deng"
    # Purchasing *.dapps.Enterprise.com wildcard cert is avoided (300€ per year).
    # This env is setup on deng.Enterprise.com dns_child_zone with a signed/purchased wildcard certificate
    # Self-signed wildcard certs are not App-Core compliant (connection between appcore and applink-cloud would fail)
deploy_Europe         = true
deploy_United_States  = false

# Enterprise Monitor Client (Prometheus exporter):
prometheus_exporter_docker_image            = "Enterprisecatalogcr.azurecr.io/monitor-client"
prometheus_exporter_docker_image_tag        = "1.0.1"

# Enterprise appanalysis aka omni-catalog:
app_docker_image                            = "Enterprisecatalogcr.azurecr.io/omni" # OMNI aka appanalysis or OMNI-Catalog
app_docker_image_tag                        = "3.0.2"

# AKS Computation:
docker_enable_ci                            = false

# MongoDB Atlas:
#oplog_size_mb                              = 990
