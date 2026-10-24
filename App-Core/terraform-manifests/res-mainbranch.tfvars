# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

dns_child_zone                      = "apps" # This env is setup on apps.Enterprise.com dns_child_zone (production)
azure_subscription_unitedstates     = "00000000-0000-0000-0000-000000000004"   # Enterprise Production Subscription (a PRO subscription)
azure_subscription_europe           = "00000000-0000-0000-0000-000000000004"   # Enterprise Production Subscription (a PRO subscription)
deploy_Europe                       = true
deploy_United_States                = false
storage_account_replication_type    = "GRS"
client_names_europe                 = ["procanaid","vhir","Enterprise","philips"]
client_names_unitedstates           = ["procanaid"]

# client_names_europe = ["client1",
#                 "client2",
#                 "client3",
#                 "client4",
#                 "client5",
#                 "Enterprise",
#                 "Enterpriseux",
#                 "client6",
#                 "client7"]

mongodb_atlas_org_id   = "000000000000000000000000"   # Enterprise

################################
# App Service - Enterprise App-Core:
################################

# Docker
app_docker_image_appcore_front_spa             = "Enterprisecorecr.azurecr.io/engine"
app_docker_image_tag_appcore_front_spa         = "1.34.0"

app_docker_image_appcore_back_api              = "Enterprisecorecr.azurecr.io/engine_backend"
app_docker_image_tag_appcore_back_api          = "1.32.0"

app_docker_image_applink_cloud_api             = "Enterprisecorecr.azurecr.io/applink_cloud"
app_docker_image_tag_applink_cloud_api         = "1.5.0"

app_docker_image_pdf_renderer                 = "Enterprisecorecr.azurecr.io/pdf_renderer"
app_docker_image_tag_pdf_renderer             = "1.1.0"

app_docker_image_analysis_viewer_frontend     = "Enterprisecorecr.azurecr.io/pipeline_viewer"
app_docker_image_tag_analysis_viewer_frontend = "2.2.0"

# App Service - Analysis viewer backend (client):
app_docker_image_analysis_viewer_backend      = "Enterprisecorecr.azurecr.io/pipeline_viewer_backend"
app_docker_image_tag_analysis_viewer_backend  = "1.9.1"

################################
# App Service
################################
docker_enable_ci                              = false # Have your custom Docker image automatically re-deployed when a new version is pushed to Docker Registry

################################
# K8S
################################
aks_computation_azure_subscription_id         = "00000000-0000-0000-0000-000000000004"   # "Enterprise Production Subscription" - December 2022: applink-cloud currently requires this AKS to be deployed within the same subscription where appcore is running.
k8s_cluster_name                              = "aks-nepro" #"aks-computation-core"
k8s_resource_group                            = "rg-sharedinfra-aks-nepro" #"rg-aks-computation-core"

################################
# MongoDB Atlas
################################
oplog_size_mb                                = 990

#############################################################################################
# Service Principal (Enterprise Application object_id) used by Azure DevOps AppLink pipeline
#############################################################################################
sp_app_link_object_id                         = "00000000-0000-0000-0000-000000000003"   # sp-applink-Enterprise-pro

########################################
# Azure Backup Policy
########################################
backup_policy_retention_monthly             = 6
