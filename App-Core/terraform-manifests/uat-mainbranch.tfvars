# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

dns_child_zone                  = "eng"  # This env is setup on eng.Enterprise.com dns_child_zone
azure_subscription_unitedstates = "00000000-0000-0000-0000-000000000002"   # Enterprise DevTest Subscription
azure_subscription_europe       = "00000000-0000-0000-0000-000000000002"   # Enterprise DevTest Subscription
deploy_Europe                   = true
deploy_United_States            = false
client_names_europe             = ["Enterprise"]
client_names_unitedstates       = ["Enterprise"]

################################
# App Service - Enterprise App-Core:
################################

# Docker
docker_registry                               = "https://Enterprisedevtestcr.azurecr.io"
docker_registry_username                      = "EnterpriseDevTestCR"

app_docker_image_appcore_front_spa             = "Enterprisedevtestcr.azurecr.io/engine"
app_docker_image_tag_appcore_front_spa         = "uat"

app_docker_image_appcore_back_api              = "Enterprisedevtestcr.azurecr.io/engine_backend"
app_docker_image_tag_appcore_back_api          = "uat"

app_docker_image_applink_cloud_api             = "Enterprisedevtestcr.azurecr.io/applink_cloud"
app_docker_image_tag_applink_cloud_api         = "uat"

app_docker_image_pdf_renderer                 = "Enterprisedevtestcr.azurecr.io/pdf_renderer"
app_docker_image_tag_pdf_renderer             = "uat"

app_docker_image_analysis_viewer_frontend     = "Enterprisedevtestcr.azurecr.io/pipeline_viewer"
app_docker_image_tag_analysis_viewer_frontend = "uat"

# App Service - Analysis viewer backend (client):
app_docker_image_analysis_viewer_backend      = "Enterprisedevtestcr.azurecr.io/pipeline_viewer_backend"
app_docker_image_tag_analysis_viewer_backend  = "uat"

####################################
# App Service
####################################
docker_enable_ci                              = true # Have your custom Docker image automatically re-deployed when a new version is pushed to Docker Registry

################################
# MongoDB Atlas
################################
oplog_size_mb                                = 3090 #4672 # With default value of 990 mb we can get an alert with the message "Replication Oplog Window has gone below 1 hours"
