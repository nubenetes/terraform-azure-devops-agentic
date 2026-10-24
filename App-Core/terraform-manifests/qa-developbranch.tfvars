# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

dns_child_zone        = "deng"  # This env is setup on deng.Enterprise.com dns_child_zone
deploy_Europe         = true
deploy_United_States  = false

################################
# App Service - Enterprise App-Core:
################################

# Docker
# docker_registry                               = "https://Enterprisedevtestcr.azurecr.io"
# docker_registry_username                      = "EnterpriseDevTestCR"

# app_docker_image_appcore_front_spa             = "Enterprisedevtestcr.azurecr.io/engine"
# app_docker_image_tag_appcore_front_spa         = "uat" # 'qa' tag is not available

# app_docker_image_appcore_back_api              = "Enterprisedevtestcr.azurecr.io/engine_backend"
# app_docker_image_tag_appcore_back_api          = "uat" # 'qa' tag is not available

# app_docker_image_applink_cloud_api             = "Enterprisedevtestcr.azurecr.io/applink_cloud"
# app_docker_image_tag_applink_cloud_api         = "uat" # 'qa' tag is not available

# app_docker_image_pdf_renderer                 = "Enterprisedevtestcr.azurecr.io/pdf_renderer"
# app_docker_image_tag_pdf_renderer             = "uat" # 'qa' tag is not available

# app_docker_image_analysis_viewer_frontend     = "Enterprisedevtestcr.azurecr.io/pipeline_viewer"
# app_docker_image_tag_analysis_viewer_frontend = "uat" # 'qa' tag is not available

# # App Service - Analysis viewer backend (client):
# app_docker_image_analysis_viewer_backend      = "Enterprisedevtestcr.azurecr.io/pipeline_viewer_backend"
# app_docker_image_tag_analysis_viewer_backend  = "uat" # 'qa' tag is not available

###############
# Prod
###############
# app_docker_image_appcore_front_spa             = "Enterprisecorecr.azurecr.io/engine"
# app_docker_image_tag_appcore_front_spa         = "1.23.3"

# app_docker_image_appcore_back_api              = "Enterprisecorecr.azurecr.io/engine_backend"
# app_docker_image_tag_appcore_back_api          = "1.23.1"

# app_docker_image_applink_cloud_api             = "Enterprisecorecr.azurecr.io/applink_cloud"
# app_docker_image_tag_applink_cloud_api         = "1.2.11_prod"

# app_docker_image_pdf_renderer                 = "Enterprisecorecr.azurecr.io/pdf_renderer"
# app_docker_image_tag_pdf_renderer             = "1.1.0"

# app_docker_image_analysis_viewer_frontend     = "Enterprisecorecr.azurecr.io/pipeline_viewer"
# app_docker_image_tag_analysis_viewer_frontend = "1.7.7"

# # App Service - Analysis viewer backend (client):
# app_docker_image_analysis_viewer_backend      = "Enterprisecorecr.azurecr.io/pipeline_viewer_backend"
# app_docker_image_tag_analysis_viewer_backend  = "1.7.6"

###############
# Dev
###############
# Docker
docker_registry                               = "https://Enterprisedevtestcr.azurecr.io"
docker_registry_username                      = "EnterpriseDevTestCR"

app_docker_image_appcore_front_spa             = "Enterprisedevtestcr.azurecr.io/engine"
app_docker_image_tag_appcore_front_spa         = "dev"

app_docker_image_appcore_back_api              = "Enterprisedevtestcr.azurecr.io/engine_backend"
app_docker_image_tag_appcore_back_api          = "dev"

app_docker_image_applink_cloud_api             = "Enterprisedevtestcr.azurecr.io/applink_cloud"
app_docker_image_tag_applink_cloud_api         = "dev"

app_docker_image_pdf_renderer                 = "Enterprisedevtestcr.azurecr.io/pdf_renderer"
app_docker_image_tag_pdf_renderer             = "dev"

app_docker_image_analysis_viewer_frontend     = "Enterprisedevtestcr.azurecr.io/pipeline_viewer"
app_docker_image_tag_analysis_viewer_frontend = "dev"

# App Service - Analysis viewer backend (client):
app_docker_image_analysis_viewer_backend      = "Enterprisedevtestcr.azurecr.io/pipeline_viewer_backend"
app_docker_image_tag_analysis_viewer_backend  = "dev"

################################
# App Service
################################
docker_enable_ci                              = true # Have your custom Docker image automatically re-deployed when a new version is pushed to Docker Registry

################################
# MongoDB Atlas
################################
oplog_size_mb                                = 3090 #4672 # With default value of 990 mb we can get an alert with the message "Replication Oplog Window has gone below 1 hours"

###############################
# AppLink
###############################
applink_onprem_azure_devops_pipeline_endpoint    = "https://dev.azure.com/EnterpriseDev/GitOps/_apis/pipelines/95/runs?api-version=7.1-preview.1"  # develop branch
