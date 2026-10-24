# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

dns_child_zone              = "deng"
    # Purchasing *.dapps.Enterprise.com wildcard cert is avoided (300€ per year).
    # This env is setup on deng.Enterprise.com dns_child_zone with a signed/purchased wildcard certificate
    # Self-signed wildcard certs are not App-Core compliant (connection between appcore and applink-cloud would fail)
deploy_Europe               = false
deploy_United_States        = false
client_names_europe         = ["Enterprise"]
client_names_unitedstates   = ["Enterprise"]

################################
# App Service - Enterprise App-Core:
################################

# Docker
app_docker_image_appcore_front_spa             = "Enterprisecorecr.azurecr.io/engine"
app_docker_image_tag_appcore_front_spa         = "demo"

app_docker_image_appcore_back_api              = "Enterprisecorecr.azurecr.io/engine_backend"
app_docker_image_tag_appcore_back_api          = "demo"

app_docker_image_applink_cloud_api             = "Enterprisecorecr.azurecr.io/applink_cloud"
app_docker_image_tag_applink_cloud_api         = "demo"

app_docker_image_pdf_renderer                 = "Enterprisecorecr.azurecr.io/pdf_renderer"
app_docker_image_tag_pdf_renderer             = "demo"

app_docker_image_analysis_viewer_frontend     = "Enterprisecorecr.azurecr.io/pipeline_viewer"
app_docker_image_tag_analysis_viewer_frontend = "demo"

# App Service - Analysis viewer backend (client):
app_docker_image_analysis_viewer_backend      = "Enterprisecorecr.azurecr.io/pipeline_viewer_backend"
app_docker_image_tag_analysis_viewer_backend  = "demo"   # "1.7.5"

################################
# App Service
################################
docker_enable_ci                              = true # Have your custom Docker image automatically re-deployed when a new version is pushed to Docker Registry

################################
# K8S
################################
# aks_computation_azure_subscription_id         = "00000000-0000-0000-0000-000000000004"   # "Enterprise Production Subscription"
# k8s_cluster_name                              = "aks-computation-core"
# k8s_resource_group                            = "rg-aks-computation-core"

################################
# MongoDB Atlas
################################
oplog_size_mb                                = 3090 #4672 #With default value of 990 mb we can get an alert with the message "Replication Oplog Window has gone below 1 hours"


#################################################
# AAD Developers Group
# Key Vault RBAC
# 25-rbac-azurerm.tf
#################################################
vault_rbac_aad_developers_group_permissions = "Key Vault Reader"

#################################################
# AAD Developers Group
# Key Vault Access Policy (1 per client)
# 22-key-vault-clients.tf
#################################################
vault_access_policy_aad_developers_group_key_permissions = [
    "Get",
    "List",
]
vault_access_policy_aad_developers_group_secret_permissions = [
    "Get",
    "List",
]
vault_access_policy_aad_developers_group_certificate_permissions = [
    "Get",
    "List",
    "GetIssuers",
]


#################################################
# Key Vault Access Policy (1 per client)
# Compound Identity - Security Principal Group
# 22-key-vault-clients.tf
#################################################

# vault_access_policy_compound_identity_security_principal_group  = "00000000-0000-0000-0000-000000000001" # AAD_Developers Security Principal Group (object_id)
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