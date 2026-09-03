################################################################
# Azure Subscription
# https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory
#################################################################
variable "azure_subscription_unitedstates" {
  description = "The azure subscription ID with Terraform apply"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # Enterprise DevOps Subscription
}
variable "azure_subscription_europe" {
  description = "The azure subscription ID with Terraform apply"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # Enterprise DevOps Subscription
}

#################################
# Azure Location
# Azure Region Codes: https://blog.nicholasrogoff.com/2019/11/13/cloud-resource-naming-convention-azure/
#################################
variable "location_europe" {
  description = "Azure Region where all these resources will be provisioned"
  type        = string
  default     = "northeurope"
}
variable "location_unitedstates" {
  description = "Azure Region where all these resources will be provisioned"
  type        = string
  default     = "centralus"
}
variable "location_code_europe" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "ne"
}
variable "location_code_unitedstates" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "cus"
}
######################################
# Feature Flags:
# Deploy on Azure Europe Region
# Deploy on Azure United States Region
######################################
variable "deploy_Europe" {
  description = "Feature Flag: Do we deploy on Azure Europe Region?"
  type        = string #bool
  default     = "true"
}
variable "deploy_United_States" {
  description = "Feature Flag: Do we deploy on Azure United States Region?"
  type        = string #bool
  default     = "false"
}

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
  default     = "10.40.25.0/24"
}

# % sipcalc 10.40.25.0/24 -s 26
# -[ipv4 : 10.40.25.0/24] - 0
#
# [Split network]
# Network			- 10.40.25.0      - 10.40.25.63
# Network			- 10.40.25.64     - 10.40.25.127
# Network			- 10.40.25.128    - 10.40.25.191
# Network			- 10.40.25.192    - 10.40.25.255
variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.40.25.0/26"
}
# variable "subnet_cidr_2" {
#   description = "Subnet CIDR 2"
#   type = string
#   default = "10.40.25.64/26"
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
  description = "A prefix for any dns based resources"
  type        = string
  default     = "appc" #  #Alternatives: appc, appc, appcore, appcore, etc
  # azurerm_linux_web_app.appcore_back_api -> obtains key-vault-client name from "kv-<AETITLE>-<APP_ENVIRONMENT>" with:
  #     APP_ENVIRONMENT  = local.appcore_dns_name
  #     appcore_dns_name  = "${var.dns_prefix}${local.gitbranch}${var.location_code}${local.env_generator}"
}
variable "dns_location_code_europe" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "ne"
}
variable "dns_location_code_unitedstates" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "cus"
}

#################################
# Enterprise Product: App-Core
#################################
variable "enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "appcore" # Alternatives: appc, appcore, appcore, etc
}

#################################
# Enterprise Product: APPC-Analysis
#################################
variable "appc_analysis_name" {
  description = "This variable defines the product"
  type        = string
  default     = "appcanalysis" # Alternatives: appcanalysis, appc-analysis, analysis, etc
}

#################################
# Enterprise Product: APPC-Link Cloud
#################################
variable "appc_link_cloud_name" {
  description = "name of appclink-cloud"
  type        = string
  default     = "appclink-cloud" # Alternatives: appclinkcloud, appclink-cloud, etc
}

##########################################################
# Service Principal used by Azure DevOps APPC-Link pipeline
##########################################################
variable "sp_appc_link_object_id" {
  description = "Service Principal (Enterprise Application object_id) used by Azure DevOps APPC-Link pipeline"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # sp-appc-link-enterprise-dev
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
  default     = "LRS" #"RAGRS"
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
variable "secret_appclink_azure_devops_endpoint_pat" {
  description = "A service user Personal Access Token required to trigger APPC-Link Azure DevOps pipeline - APPC_LINK_DOWNLOAD_KEY in 11-app-service.tf"
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
  default     = "P2v2" #"P1v2" # https://azure.microsoft.com/en-us/pricing/details/app-service/windows/
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
variable "client_names_europe" {
  description = "Create Azure resources with these client names"
  type        = list(any)
  default = ["client1",
  "client2"]
  # validation {
  #    # https://spacelift.io/blog/how-to-use-terraform-variables
  #    # https://jeffbrown.tech/terraform-variables-validation/
  #    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char
  #    condition     = alltrue([for each in var.client_names : (length("${each}") < 9) ? true:false])  # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
  #    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  # }

}
variable "client_names_unitedstates" {
  description = "Create Azure resources with these client names"
  type        = list(any)
  default     = ["client3"]
  # validation {
  #    # https://spacelift.io/blog/how-to-use-terraform-variables
  #    # https://jeffbrown.tech/terraform-variables-validation/
  #    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char
  #    condition     = alltrue([for each in var.client_names : (length("${each}") < 9) ? true:false])  # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
  #    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  # }

}


#################################################################################################
# Test Users
#################################################################################################
variable "test_user1" {
  description = "Create test user without admin permissions"
  type        = string
  default     = "test_user1"
}
variable "test_admin" {
  description = "Create test user with admin permissions"
  type        = string
  default     = "test_admin"
}


#######################
# APPC Link
#######################
variable "appclink_onprem_azure_devops_pipeline_endpoint" {
  description = "Azure DevOps Pipeline Endpoing that triggers a APPC-Link Build + Download URL available at https://dev.azure.com/EnterpriseDev/_git/APPC-Link"
  type        = string
  default     = "https://dev.azure.com/EnterpriseDev/APPC-Link/_apis/pipelines/34/runs?api-version=7.1-preview" # main branch (pro)
}

#################################
# Docker
#################################
variable "docker_registry" {
  description = "Docker Registry Server URL"
  type        = string
  default     = "https://enterpriseappcorecr.azurecr.io"
}
variable "docker_registry_username" {
  description = "Docker Registry Username"
  type        = string
  default     = "EnterpriseAppcoreCR"
  sensitive   = true
}

##################################
# Docker Images 1/2 - MAIN BRANCH
# App Service - Enterprise App-Core:
##################################
variable "app_docker_image_appcore_front_spa" {
  description = "App-Core Portal Frontend Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/enterprise_app"
}
variable "app_docker_image_tag_appcore_front_spa" {
  description = "App-Core Portal Frontend Image Tag"
  type        = string
  default     = "1.8.0"
}
variable "app_docker_image_appcore_back_api" {
  description = "App-Core Portal Backend Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/enterprise_app_backend"
}
variable "app_docker_image_tag_appcore_back_api" {
  description = "App-Core Portal Backend Image Tag"
  type        = string
  default     = "1.8.0"
}
variable "app_docker_image_appclink_cloud_api" {
  description = "App-Core APPC-Link Cloud Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/appcore_link_cloud"
}
variable "app_docker_image_tag_appclink_cloud_api" {
  description = "App-Core APPC-Link Cloud Docker Image Tag"
  type        = string
  default     = "1.2.0"
}
variable "app_docker_image_pdf_renderer" {
  description = "App-Core PDF Renderer Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/pdf_renderer"
}
variable "app_docker_image_tag_pdf_renderer" {
  description = "App-Core PDF Renderer Docker Image Tag"
  type        = string
  default     = "1.1.0"
}
variable "app_docker_image_analysis_viewer_frontend" {
  description = "App-Core Analysis Viewer Frontend Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/pipeline_viewer"
}
variable "app_docker_image_tag_analysis_viewer_frontend" {
  description = "App-Core Analysis Viewer Frontend Docker Image Tag"
  type        = string
  default     = "1.7.4"
}
##################################################
# Docker Images 1/2 - MAIN BRANCH
# App Service - Analysis viewer backend (client):
##################################################
variable "app_docker_image_analysis_viewer_backend" {
  description = "App-Core Analysis Viewer Backend Docker Image"
  type        = string
  default     = "enterpriseappcorecr.azurecr.io/pipeline_viewer_backend"
}
variable "app_docker_image_tag_analysis_viewer_backend" {
  description = "App-Core Analysis Viewer Backend Docker Image Tag"
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
#   default     = "enterpriseappcorecr.azurecr.io/enterprise_app"
# }
# variable "app_docker_image_tag_appcore_front_spaDevelopBranch" {
#   description = "App-Core Portal Frontend Image Tag"
#   type        = string
#   default     = "1.8.0"
# }
# variable "app_docker_image_appcore_back_apiDevelopBranch" {
#   description = "App-Core Portal Backend Docker Image"
#   type        = string
#   default     = "enterpriseappcorecr.azurecr.io/enterprise_app_backend"
# }
# variable "app_docker_image_tag_appcore_back_apiDevelopBranch" {
#   description = "App-Core Portal Backend Image Tag"
#   type        = string
#   default     = "1.8.0"
# }
# variable "app_docker_image_appclink_cloud_apiDevelopBranch" {
#   description = "App-Core APPC-Link Cloud Docker Image"
#   type        = string
#   default     = "enterpriseappcorecr.azurecr.io/appcore_link_cloud"
# }
# variable "app_docker_image_tag_appclink_cloud_apiDevelopBranch" {
#   description = "App-Core APPC-Link Cloud Docker Image Tag"
#   type        = string
#   default     = "1.2.0"
# }
#   description = "App-Core PDF Renderer Docker Image"
#   type        = string
# }
#   description = "App-Core PDF Renderer Docker Image Tag"
#   type        = string
#   default     = "1.1.0"
# }
# variable "app_docker_image_analysis_viewer_frontendDevelopBranch" {
#   description = "App-Core Analysis Viewer Frontend Docker Image"
#   type        = string
#   default     = "enterpriseappcorecr.azurecr.io/pipeline_viewer"
# }
# variable "app_docker_image_tag_analysis_viewer_frontendDevelopBranch" {
#   description = "App-Core Analysis Viewer Frontend Docker Image Tag"
#   type        = string
#   default     = "1.7.4"
# }
##################################################
# Docker Images 2/2 - DEVELOP BRANCH
# App Service - Analysis viewer backend (client):
##################################################
# variable "app_docker_image_analysis_viewer_backendDevelopBranch" {
#   description = "App-Core Analysis Viewer Backend Docker Image"
#   type        = string
#   default     = "enterpriseappcorecr.azurecr.io/pipeline_viewer_backend"
# }
# variable "app_docker_image_tag_analysis_viewer_backendDevelopBranch" {
#   description = "App-Core Analysis Viewer Backend Docker Image Tag"
#   type        = string
#   default     = "1.7.5"
# }

################################
# AKS Computation - Kubernetes
################################
variable "aks_computation_azure_subscription_id" {
  description = "Azure Subscription ID with AKS Computation"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # "Enterprise DevTest Subscription"
}
variable "k8s_cluster_name" {
  description = "Kubernetes Cluster Name"
  type        = string
  default     = "aks-neeng" #"aks-computation-devtest" # "aks-computation-appcore"
}
variable "k8s_resource_group" {
  description = "Azure RG with AKS"
  type        = string
  default     = "rg-sharedinfra-aks-neeng" #"rg-aks-computation-devtest"
  sensitive   = true
}
variable "k8s_namespace" {
  description = "k8s namespace with AKS Computation"
  type        = string
  default     = "enterprise"
  sensitive   = true
}

# variable "k8s_cluster_url" {
#   description = "Kubernetes Cluster URL"
#   type        = string
#   default     = "https://aks-computation-devtest-189dd498.hcp.northeurope.azmk8s.io:443"
# }
# variable "k8s_namespace" {
#   description = "Kubernetes Namespace" # K8_CONTEXT_NAME in 11-app-service.tf
#   type        = string
#   default     = "enterprise"
# }
# variable "k8s_username" {
#   description = "Kubernetes Username"
#   type        = string
#   default     = "clusterAdmin_rg-aks-computation-devtest_aks-computation-devtest"
#   sensitive   = true
# }

variable "secret_aks_kube_config_host_europe" {
  description = "aks_kube_config_host"
  type        = string
  sensitive   = true
  default     = "rg-sharedinfra-aks-neeng-b360a135.hcp.northeurope.azmk8s.io:443"
}

variable "secret_aks_kube_config_client_certificate_europe" {
  description = "aks_kube_config_client_certificate"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_aks_kube_config_client_key_europe" {
  description = "aks_kube_config_client_key"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_aks_kube_config_cluster_ca_certificate_europe" {
  description = "aks_kube_config_cluster_ca_certificate"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_aks_kube_config_host_unitedstates" {
  description = "aks_kube_config_host"
  type        = string
  sensitive   = true
  default     = "rg-sharedinfra-aks-neeng-16e7a689.hcp.northeurope.azmk8s.io:443"
}

variable "secret_aks_kube_config_client_certificate_unitedstates" {
  description = "aks_kube_config_client_certificate"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_aks_kube_config_client_key_unitedstates" {
  description = "aks_kube_config_client_key"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_aks_kube_config_cluster_ca_certificate_unitedstates" {
  description = "aks_kube_config_cluster_ca_certificate"
  type        = string
  sensitive   = true
  default     = "value"
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
  #default     = "00000000-0000-0000-0000-000000000000"  # AAD_Administrators Security Group
  default = "00000000-0000-0000-0000-000000000000" # AAD_azure_devops_admins Security Group
}

########################################
# New Analysis Viewer with 6 views
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
  default     = 0
}

# variable "backup_policy_retention_yearly" {
#   description = "Azure Backup Policy Retention Yearly"
#   type        = number
#   default     = 1
# }
