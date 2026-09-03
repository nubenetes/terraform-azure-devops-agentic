#################################
# Azure Location
# Azure Region Codes: https://blog.nicholasrogoff.com/2000/01/01/cloud-resource-naming-convention-azure/
#################################
variable "location" {
  description = "Azure Region where all these resources will be provisioned"
  type        = string
  default     = "northeurope"
}
variable "location_code" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "ne"
}

#########################################
# Azure Subscription (Deployment Target)
#########################################
# variable "azure_subscription" {
#   description = "The azure subscription ID with Terraform apply"
#   type        = string
# }

#################################
# RG Prefix
#################################
variable "rg_prefix" {
  description = "The prefix which should be used for all rg resources"
  type        = string
  default     = "rg"
}
#################################
# Azure Environment Name
#################################
variable "environment" {
  description = "This variable defines the Environment"
  type        = string
  default     = "dev"
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  default     = "develop"
}

###################
# AAD Tenant ID
###################
variable "aad_tenant_id" {
  description = "This variable defines AAD Tenant ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

#############
# Azure VNet
#############
variable "vnet_cidr" {
  description = "VNet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

# % sipcalc 10.10.0.0/24 -s 26
# -[ipv4 : 10.10.0.0/24] - 0
#
# [Split network]
# Network			- 10.10.0.0      - 10.10.0.63
# Network			- 10.10.0.64     - 10.10.0.127
# Network			- 10.10.0.128    - 10.10.0.191
# Network			- 10.10.0.192    - 10.10.0.255
variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.10.0.0/26"
}
# variable "subnet_cidr_2" {
#   description = "Subnet CIDR 2"
#   type = string
#   default = "10.10.0.64/26"
# }

#######################
# DNS
#######################
variable "dns_parent_zone" {
  description = "DNS Parent Zone"
  type        = string
  default     = "enterprise.com" # Don't change this
}
variable "dns_child_zone" {
  description = "DNS Child Zone"
  type        = string
  default     = "eng"
}
variable "dns_prefix" {
  description = "A prefix for App-Core portal dns based resources"
  type        = string
  default     = "appcore" # Alternatives: app, appcore, core, etc
}
variable "dns_prefix_viewer" {
  description = "A prefix for app-analysis-viewer dns based resources"
  type        = string
  default     = "appp"
}
variable "dns_location_code" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "ne"
}
#################################
# Enterprise Product: App-Core
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "appcore" # Alternatives: app, appcore, core, etc
}

variable "Enterprise_product_k8s_prefix" {
  description = "This variable defines the product"
  type        = string
  default     = "appc"
}

#################################
# Enterprise Product: app-analysis
#################################
variable "app-analysis-service_name" {
  description = "This variable defines the product"
  type        = string
  default     = "app-analysis" # Alternatives: app-analysis, app-analysis, analysis, etc
}

#################################
# Enterprise Product: App-Link Cloud
#################################
variable "app_link_cloud_name" {
  description = "This variable defines the product"
  type        = string
  default     = "applink-cloud" # Alternatives: applinkcloud, applink-cloud, etc
}

##########################################################
# Service Principal used by Azure DevOps App-Link pipeline
##########################################################
variable "sp_app_link_object_id" {
  description = "Service Principal (Enterprise Application object_id) used by Azure DevOps App-Link pipeline"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # sp-App-Link-Enterprise-dev
}

#################################
# Azure Storage Account
#################################
variable "storage_prefix" {
  description = "The prefix which should be used for all storage resources"
  type        = string
  default     = "stappcore"
}
variable "storage_account_tier" {
  description = "storage account tier"
  type        = string
  default     = "Standard"
}
variable "storage_account_replication_type" {
  description = "storage account replication type"
  type        = string
  default     = "LRS" #"RAGRS" #"LRS"
}
# variable "storage_account_kind" {
#   description = "storage account kind"
#   type = string
#   default =  "StorageV2"  #"FileStorage"
# }

##################
# Secrets
##################
variable "secret_appGatewayListenerSecure" {
  description = "content of certificate.pfx file to be imported into appcore's app gateway"
  sensitive   = true
}
# variable "secret_certificate_passphrase" {
#   description = "passphrase of certificate.pfx file to be imported into appcore's app gateway"
#   sensitive   = true
# }
variable "secret_docker_registry_server_password" {
  description = "DOCKER_REGISTRY_SERVER_PASSWORD in 11-app-service.tf"
  sensitive   = true
}
variable "secret_applink_azure_devops_endpoint_pat" {
  description = "A service user Personal Access Token required to trigger App-Link Azure DevOps pipeline - applink_DOWNLOAD_KEY in 11-app-service.tf"
  sensitive   = true
}

####################
# App Gateway
####################
variable "frontend_ip_configuration_name" {
  default = "appGwIPconf"
}
variable "gateway_ip_configuration_name" {
  default = "gatewayIpConf"
}

####################
# App Service
####################

# variable "plan_tier" {
#   type        = string
#   description = "The tier of app service plan to create"
#   default     = "Standard"
# }
variable "plan_sku" {
  description = "The sku of app service plan to create"
  type        = string
  default     = "P1v2"
}

variable "docker_enable_ci" {
  description = "DOCKER_ENABLE_CI in App Service"
  type        = string
  default     = true
}

#################################################################################################
# List of Clients
# https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
#################################################################################################
variable "client_names" {
  description = "Create Azure resources with these client names"
  #type        = list(string)
  type = list(any)
  default = ["client-anon",
  "client2"]
  # validation {
  #   # https://spacelift.io/blog/how-to-use-terraform-variables
  #   # https://jeffbrown.tech/terraform-variables-validation/
  #   # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char
  #   condition     = alltrue([for each in var.client_names : (length("${each}") < 9) ? true:false])  # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
  #   error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  # }
}

#################################################################################################
# Test Users
#################################################################################################
variable "testuser1" {
  description = "Create test user without admin permissions"
  type        = string
  default     = "testuser1"
}
variable "testadmin" {
  description = "Create test user with admin permissions"
  type        = string
  default     = "testadmin"
}

################################################################################################
# MONGODB ATLAS
# mongodb secrets setup as non-sensitive to see traces of mongoimport during the creation_time
################################################################################################
variable "oplog_size_mb" {
  description = "(Optional) The custom oplog size of the cluster. Without a value that indicates that the cluster users the default oplog size calculated by Atlas"
  type        = number
  default     = null
  # A value that represents absence or omission. If you set an argument of a resource to null, Terraform behaves as though you had completely omitted it — it will use
  # the argument's default value if it has one, or raise an error if the argument is mandatory. null is most useful in conditional expressions, so you can dynamically omit an argument if a condition isn't met.
  # Examples: 990 3090 4672
  # You can't set the oplog to less than 990 megabytes. https://www.mongodb.com/docs/atlas/cluster-additional-settings/
}
variable "secret_mongodb_atlas_public_key" {
  description = "Public Programmatic API key to authenticate to Atlas"
  type        = string
  sensitive   = false
}
variable "secret_mongodb_atlas_private_key" {
  description = "Private Programmatic API key to authenticate to Atlas"
  type        = string
  sensitive   = false
}
variable "mongodb_atlas_org_id" {
  description = "MongoDB Organization ID"
  type        = string
  default     = "000000000000000000000000" # EnterpriseDEVTEST
  sensitive   = false
}
variable "mongodb_atlas_cloud_provider" {
  description = "The cloud provider to use, must be AWS, GCP or AZURE"
  type        = string
  default     = "AZURE"
}
variable "mongodb_atlas_region" {
  # https://www.mongodb.com/docs/atlas/reference/microsoft-azure/#microsoft-azure
  description = "MongoDB Atlas Cluster Region, must be a region for the provider given"
  type        = string
  default     = "EUROPE_NORTH"
  #default     = "EUROPE_WEST"
}
variable "mongodb_atlas_mongodbversion" {
  description = "The Major MongoDB Version"
  type        = string
  default     = "5.0" # Atlas supports the following MongoDB versions for M10+ clusters: 4.0, 4.2, 4.4, 5.0 or 6.0
}
variable "mongodb_atlas_dbadmin" {
  description = "MongoDB Atlas Database Admin User Name"
  type        = string
  default     = "Enterpriseadmin"
  sensitive   = false
}
variable "secret_mongodb_atlas_dbadmin_password" {
  description = "MongoDB Atlas Database Admin Password"
  type        = string
  sensitive   = false
}
variable "mongodb_atlas_dbuser" {
  description = "MongoDB Atlas Database User Name"
  type        = string
  default     = "Enterpriseuser"
  sensitive   = false
}
variable "secret_mongodb_atlas_dbuser_password" {
  description = "MongoDB Atlas Database User Password"
  type        = string
  sensitive   = false
}
variable "mongodb_atlas_database_name" {
  description = "The database in the cluster to limit the database user to, the database does not have to exist yet"
  type        = string
  default     = "core"
}
variable "mongodb_atlas_cidr_block" {
  description = "The cidr range that the cluster will be accessed from"
  type        = string
  default     = "0.0.0.0/0" # any address is allowed
}
# variable "mongodb_atlas_ip_address" {
#   description = "The IP address that the cluster will be accessed from, can also be a CIDR range or AWS security group"
#   type        = string
#   default     =             # "0.0.0.0" is not valid
# }


#######################
# app Link
#######################
variable "applink_onprem_azure_devops_pipeline_endpoint" {
  type = string
}

#################################
# Docker
#################################
variable "docker_registry" {
  description = "Docker Registry Server URL"
  type        = string
  default     = "https://enterpriseappcr.azurecr.io"
}
variable "docker_registry_username" {
  description = "Docker Registry Username"
  type        = string
  default     = "enterpriseappcr"
  sensitive   = true
}

##################################
# Docker Images 1/2 - MAIN BRANCH
# App Service - Enterprise App-Core:
##################################
variable "app_docker_image_appcore_front_spa" {
  description = "App-Core Portal Frontend Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/enterprise_engine"
}
variable "app_docker_image_tag_appcore_front_spa" {
  description = "App-Core Portal Frontend Image Tag"
  type        = string
  default     = "1.8.0"
}
variable "app_docker_image_appcore_back_api" {
  description = "App-Core Portal Backend Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/enterprise_engine_backend"
}
variable "app_docker_image_tag_appcore_back_api" {
  description = "App-Core Portal Backend Image Tag"
  type        = string
  default     = "1.8.0"
}
variable "app_docker_image_applink_cloud_api" {
  description = "App-Core App-Link Cloud Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/applink_cloud"
}
variable "app_docker_image_tag_applink_cloud_api" {
  description = "App-Core App-Link Cloud Docker Image Tag"
  type        = string
  default     = "1.2.0"
}
variable "app_docker_image_pdf_renderer" {
  description = "App-Core PDF Renderer Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/pdf_renderer"
}
variable "app_docker_image_tag_pdf_renderer" {
  description = "App-Core PDF Renderer Docker Image Tag"
  type        = string
  default     = "1.1.0"
}
variable "app_docker_image_analysis_viewer_frontend" {
  description = "App-Core analysis Viewer Frontend Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/pipeline_viewer"
}
variable "app_docker_image_tag_analysis_viewer_frontend" {
  description = "App-Core analysis Viewer Frontend Docker Image Tag"
  type        = string
  default     = "1.7.4"
}
variable "secret_applink_cloud_email_apikey" {
  description = "applink_cloud_email_apikey"
  type        = string
  sensitive   = true
  default     = "default value"
}
##################################################
# Docker Images 1/2 - MAIN BRANCH
# App Service - analysis viewer backend (client):
##################################################
variable "app_docker_image_analysis_viewer_backend" {
  description = "App-Core analysis Viewer Backend Docker Image"
  type        = string
  default     = "enterpriseappcr.azurecr.io/pipeline_viewer_backend"
}
variable "app_docker_image_tag_analysis_viewer_backend" {
  description = "App-Core analysis Viewer Backend Docker Image Tag"
  type        = string
  default     = "1.7.5"
}

######################################
# Docker Images 2/2 - DEVELOP BRANCH
# App Service - Enterprise App-Core:
######################################
# variable "app_docker_image_appcore_front_spaDevelopBranch" {
#   description = "App-Core Portal Frontend Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/enterprise_engine"
# }
# variable "app_docker_image_tag_appcore_front_spaDevelopBranch" {
#   description = "App-Core Portal Frontend Image Tag"
#   type        = string
#   default     = "1.8.0"
# }
# variable "app_docker_image_appcore_back_apiDevelopBranch" {
#   description = "App-Core Portal Backend Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/enterprise_engine_backend"
# }
# variable "app_docker_image_tag_appcore_back_apiDevelopBranch" {
#   description = "App-Core Portal Backend Image Tag"
#   type        = string
#   default     = "1.8.0"
# }
# variable "app_docker_image_applink_cloud_apiDevelopBranch" {
#   description = "App-Core App-Link Cloud Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/applink_cloud"
# }
# variable "app_docker_image_tag_applink_cloud_apiDevelopBranch" {
#   description = "App-Core App-Link Cloud Docker Image Tag"
#   type        = string
#   default     = "1.2.0"
# }
# variable "app_docker_image_pdf_rendererDevelopBranch" {
#   description = "App-Core PDF Renderer Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/pdf_renderer"
# }
# variable "app_docker_image_tag_pdf_rendererDevelopBranch" {
#   description = "App-Core PDF Renderer Docker Image Tag"
#   type        = string
#   default     = "1.1.0"
# }
# variable "app_docker_image_analysis_viewer_frontendDevelopBranch" {
#   description = "App-Core analysis Viewer Frontend Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/pipeline_viewer"
# }
# variable "app_docker_image_tag_analysis_viewer_frontendDevelopBranch" {
#   description = "App-Core analysis Viewer Frontend Docker Image Tag"
#   type        = string
#   default     = "1.7.4"
# }
##################################################
# Docker Images 2/2 - DEVELOP BRANCH
# App Service - analysis viewer backend (client):
##################################################
# variable "app_docker_image_analysis_viewer_backendDevelopBranch" {
#   description = "App-Core analysis Viewer Backend Docker Image"
#   type        = string
#   default     = "enterpriseappcr.azurecr.io/pipeline_viewer_backend"
# }
# variable "app_docker_image_tag_analysis_viewer_backendDevelopBranch" {
#   description = "App-Core analysis Viewer Backend Docker Image Tag"
#   type        = string
#   default     = "1.7.5"
# }

################################
# AKS Computation - Kubernetes
################################
variable "aks_computation_azure_subscription_id" {
  description = "Azure Subscription ID with AKS Computation"
  type        = string
  #default     = "00000000-0000-0000-0000-000000000000" # "Enterprise Example-Dev-Subscription"
}
variable "k8s_cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
  default     = "aks-computation-devtest" # "aks-computation-appcore"
}
variable "k8s_resource_group" {
  description = "Azure RG with AKS"
  type        = string
  default     = "rg-aks-computation-devtest"
  sensitive   = true
}
variable "k8s_namespace" {
  description = "k8s namespace with AKS Computation"
  type        = string
  default     = "Enterprise"
  sensitive   = true
}

#########################################################################################################################
# Key Vault Settings
# Vault Purge Protection: Disabled even on Production, since this needs to be fully automated via terraform lifecycle
#########################################################################################################################
# variable "vault_purge_protection_enabled" {
#   # (Optional) Once Purge Protection has been Enabled it's not possible to Disable it.
#   description = "purge_protection_enabled in azure key vaults"
#   type        = bool
#   default     = false  # DO NOT enable this! once Purge Protection has been Enabled it's not possible to disable it
# }
# variable "vault_soft_delete_retention_days" {
#   # (Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days.
#   description = "purge_protection_enabled in azure key vaults"
#   type        = number
#   default     = null
# }

#################################################
# Key Vault Access Policy (1 per client)
# Compound Identity - Security Principal Group
# 15-key-vault-clients.tf
#################################################
# variable "vault_access_policy_compound_identity_security_principal_group" {
#   description = "Compound Identity Security Principal Group"
#   type        = string
#   default     = "00000000-0000-0000-0000-000000000000" # AAD_Developers Security Principal Group (object_id)
# }

########################################
# compound_identity_appcore_back_api_app_role_admin
########################################
variable "vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions" {
  description = "Compound Identity Vault Access Policy Key Permissions"
  type        = list(string)
  default = [
    "Get",
    "Create",
    "List",
    "Delete",
    "Update",
  ]
}

variable "vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions" {
  description = "Compound Identity Vault Access Policy Secret Permissions"
  type        = list(string)
  default = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Recover",
    "Purge",
    "Restore",
  ]
}

variable "vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions" {
  description = "Compound Identity Vault Access Policy Certificate Permissions"
  type        = list(string)
  default = [
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
}

########################################
# compound_identity_appcore_back_api_app_role_viewer
########################################
variable "vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions" {
  description = "Compound Identity Vault Access Policy Key Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
  ]
}

variable "vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions" {
  description = "Compound Identity Vault Access Policy Secret Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
    "Set",
  ]
}

variable "vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions" {
  description = "Compound Identity Vault Access Policy Certificate Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
    "GetIssuers",
  ]
}

########################################
# AAD DEVELOPERS GROUP principal_id
########################################
variable "aad_developers_group" {
  description = "Azure AD Group principal_id with developers that require access to a deployed RG"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # AAD_azure_devops_developers
}
variable "aad_developers_group_assigned_role" {
  description = "Built-in role assigned to AAD Developers Group"
  type        = string
  default     = "Reader" # Built-in role: View all resources, but does not allow you to make any changes.
}

variable "aad_developers_group_storage_blob_assigned_role" {
  description = "Built-in storage blob role assigned to AAD Developers Group"
  type        = string
  default     = "Storage Blob Data Reader" # Built-in role: Allows for read access to Azure Storage blob containers and data.
}

#################################################
# AAD DEVELOPERS GROUP - RBAC
#################################################

variable "vault_rbac_aad_developers_group_permissions" {
  description = "Built-in Key Vault role assigned to AAD Developers Group"
  type        = string
  default     = "Key Vault Reader" # Built-in role
}

#################################################
# AAD DEVELOPERS GROUP - Key Vault Access Policy
#################################################
variable "vault_access_policy_aad_developers_group_key_permissions" {
  description = "Compound Identity Vault Access Policy Key Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
  ]
}

variable "vault_access_policy_aad_developers_group_secret_permissions" {
  description = "Compound Identity Vault Access Policy Secret Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
  ]
}

variable "vault_access_policy_aad_developers_group_certificate_permissions" {
  description = "Compound Identity Vault Access Policy Certificate Permissions"
  type        = list(string)
  default = [
    "Get",
    "List",
    "GetIssuers",
  ]
}

########################################
# AAD_Administrators Security Group
########################################
variable "aad_administrators_group" {
  description = "AAD_Administrators Security Group"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # AAD_Administrators Security Group
}

########################################
# New analysis Viewer with 6 views
########################################
variable "new_analysis_viewer_with_six_views" {
  description = "Enable new analysis viewer with 6 views"
  type        = string
  default     = "false"
}

########################################
# Azure Backup Policy
########################################

variable "backup_policy_retention_daily" {
  description = "Azure Backup Policy Retention Daily"
  type        = number
  default     = 7
}

variable "backup_policy_retention_weekly" {
  description = "Azure Backup Policy Retention Weekly"
  type        = number
  default     = 4
}

variable "backup_policy_retention_monthly" {
  description = "Azure Backup Policy Retention Monthly"
  type        = number
  default     = 6
}

# variable "backup_policy_retention_yearly" {
#   description = "Azure Backup Policy Retention Yearly"
#   type        = number
#   default     = 0
# }
