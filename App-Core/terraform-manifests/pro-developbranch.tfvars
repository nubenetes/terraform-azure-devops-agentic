# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

dns_child_zone        = "deng"
    # Purchasing *.dapps.Enterprise.com wildcard cert is avoided (300€ per year).
    # This env is setup on deng.Enterprise.com dns_child_zone with a signed/purchased wildcard certificate
    # Self-signed wildcard certs are not App-Core compliant (connection between appcore and applink-cloud would fail)
deploy_Europe         = true
deploy_United_States  = false

# client_names_europe = ["client1",
#                 "client2",
#                 "client3",
#                 "client4",
#                 "client5",
#                 "Enterprise",
#                 "Enterpriseux",
#                 "client6",
#                 "client7"]

################################
# App Service - Enterprise App-Core:
################################

# Docker
app_docker_image_appcore_front_spa             = "Enterprisecorecr.azurecr.io/engine"
app_docker_image_tag_appcore_front_spa         = "1.23.3"

app_docker_image_appcore_back_api              = "Enterprisecorecr.azurecr.io/engine_backend"
app_docker_image_tag_appcore_back_api          = "1.23.1"

app_docker_image_applink_cloud_api             = "Enterprisecorecr.azurecr.io/applink_cloud"
app_docker_image_tag_applink_cloud_api         = "1.2.11_prod"

app_docker_image_pdf_renderer                 = "Enterprisecorecr.azurecr.io/pdf_renderer"
app_docker_image_tag_pdf_renderer             = "1.1.0"

app_docker_image_analysis_viewer_frontend     = "Enterprisecorecr.azurecr.io/pipeline_viewer"
app_docker_image_tag_analysis_viewer_frontend = "1.7.7"

# App Service - Analysis viewer backend (client):
app_docker_image_analysis_viewer_backend      = "Enterprisecorecr.azurecr.io/pipeline_viewer_backend"
app_docker_image_tag_analysis_viewer_backend  = "1.7.6"

################################
# App Service
################################
docker_enable_ci                              = false # Have your custom Docker image automatically re-deployed when a new version is pushed to Docker Registry

################################################################################################################################################################
# K8S
# Do NOT try to connect to AKS Legacy PRO running in Enterprise Production Subscription (we don't want to assign Owner Role to a SP deploying IaC from develop branch)
################################################################################################################################################################
# aks_computation_azure_subscription_id         = "00000000-0000-0000-0000-000000000004"   # "Enterprise Production Subscription"
# k8s_cluster_name                              = "aks-computation-core"
# k8s_resource_group                            = "rg-aks-computation-core"

################################
# MongoDB Atlas
################################
oplog_size_mb                                = 990

#############################################################################################
# Service Principal (Enterprise Application object_id) used by Azure DevOps AppLink pipeline
#############################################################################################
sp_app_link_object_id                         = "00000000-0000-0000-0000-000000000003"   # sp-applink-Enterprise-pro
