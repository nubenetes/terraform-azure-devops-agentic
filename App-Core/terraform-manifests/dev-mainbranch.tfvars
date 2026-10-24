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
client_names_europe             = ["Enterprise","client1"]
client_names_unitedstates       = ["Enterprise"]

################################
# Permissions:
################################
aad_developers_group_assigned_role            = "Owner" #"Contributor"

################################
# App Service - Enterprise App-Core:
################################

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
oplog_size_mb                                = 3090 #4672 #With default value of 990 mb we can get an alert with the message "Replication Oplog Window has gone below 1 hours"


#################################################
# AAD Developers Group
# Key Vault RBAC
# 25-rbac-azurerm.tf
#################################################
vault_rbac_aad_developers_group_permissions = "Key Vault Administrator"

#################################################
# Key Vault Access Policy (1 per client)
# AAD Developers Group
# 22-key-vault-clients.tf
#################################################
vault_access_policy_aad_developers_group_key_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "Update",
]
vault_access_policy_aad_developers_group_secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Recover",
    "Purge",
    "Restore",
]
vault_access_policy_aad_developers_group_certificate_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "GetIssuers",
    "DeleteIssuers",
    "Recover",
    "Restore",
    "Purge",
    "Update",
    "Import",
]

#################################################
# Key Vault Access Policy (1 per client)
# Compound Identity - Security Principal Group
# 15-key-vault-clients.tf
#################################################

# vault_access_policy_compound_identity_security_principal_group                      = "00000000-0000-0000-0000-000000000001" # AAD_Developers Security Principal Group (object_id)
# vault_access_policy_compound_identity_key_permissions           = [
#       "Get",
#       "Create",
#       "List",
#       "Delete",
#       "Update",
#     ]
# vault_access_policy_compound_identity_secret_permissions        = [
#       "Get",
#       "Set",
#       "List",
#       "Delete",
#       "Recover",
#       "Purge",
#       "Restore",
#     ]
# vault_access_policy_compound_identity_certificate_permissions   = [
#       "Get",
#       "Create",
#       "List",
#       "Delete",
#       "GetIssuers",
#       "DeleteIssuers",
#       "Recover",
#       "Restore",
#       "Purge",
#       "Update",
#       "Import",
#     ]

###############################
# AppLink
###############################
applink_onprem_azure_devops_pipeline_endpoint    = "https://dev.azure.com/EnterpriseDev/GitOps/_apis/pipelines/95/runs?api-version=7.1-preview.1"  # develop branch
