
#################################
# Azure Subscription
# https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory
#################################

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
# Azure Region Codes: https://blog.nicholasrogoff.com/2000/01/01/cloud-resource-naming-convention-azure/
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
  #default = "10.20.0.0/24"
  default = "10.10.0.0/24"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  #default = "10.20.0.0/27"
  default = "10.10.0.0/27"
}

#######################
# DNS
#######################
variable "dns_parent_zone" {
  description = "DNS Zone"
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
  default     = "disc" # Alternatives: qd, dis, appanalysis, etc
  # azurerm_linux_web_app.App-Core_back_api -> obtains key-vault-client name from "kv-<AETITLE>-<APP_ENVIRONMENT>" with:
  #     APP_ENVIRONMENT  = local.App-Core_dns_name
  #     App-Core_dns_name  = "${var.dns_prefix}${local.gitbranch}${var.location_code}${local.env_generator}"
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
# Enterprise Product: AppAnalysis
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "App-Catalog" # Alternatives: qd, dis, appanalysis, etc
}

#################################
# Azure Storage Account
#################################
variable "storage_prefix" {
  description = "The prefix which should be used for all storage resources"
  type        = string
  default     = "stdisc"
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
  description = "content of certificate.pfx file to be imported into app gateway"
  sensitive   = true
}

variable "secret_docker_registry_server_password" {
  description = "DOCKER_REGISTRY_SERVER_PASSWORD in 10-app-service.tf"
  sensitive   = true
}
variable "secret_app_analysis_config_key" {
  description = "config_key & Enterprise_key in 10-app-service.tf"
  sensitive   = true
}

####################
# App Gateway
####################
variable "backend_address_pool_name" {
  default = "backendPool"
}
variable "frontend_port_name" {
  default = "frontendPort"
}
variable "frontend_port_name_secure" {
  default = "frontendPortSecure"
}
variable "frontend_ip_configuration_name" {
  default = "appGwIPconfig"
}
variable "gateway_ip_configuration_name" {
  default = "gateway-ip-config"
}
variable "backend_http_settings_name" {
  default = "backendHttpsSetting"
}
variable "listener_name" {
  default = "listener"
}
variable "listener_name_secure" {
  default = "listenerSecure"
}
variable "request_routing_rule_name" {
  default = "routingRule"
}
variable "request_routing_rule_name_secure" {
  default = "routingRuleSecure"
}
variable "redirect_configuration_name" {
  default = "redirectConfig"
}
variable "probe_name" {
  default = "probeName"
}
variable "cookie_name" {
  default = "cookieName"
}

####################
# App Service
####################

# variable "plan_tier" {
#   description = "The tier of app service plan to create"
#   type        = string
#   default     = "Standard"
# }
variable "plan_sku" {
  description = "The sku of app service plan to create"
  type        = string
  default     = "P2v2"
}
variable "prometheus_push_gateway" {
  #https://enterprise.atlassian.net/wiki/spaces/DEV/pages/00000000
  description = "IP addr of Prometheus Push Gateway, used by App Service Monitor Client (a prometheus exporter)"
  type        = string
  default     = "pushgateway-app-analysis.enterprise.com" # Production
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
  type        = list(string)
  default     = ["client-anon"]
  validation {
    # https://spacelift.io/blog/how-to-use-terraform-variables
    # https://jeffbrown.tech/terraform-variables-validation/
    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char.
    # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
    # In consequence our client names cannot be longer than 8 char with the current naming scheme in our terraform code
    condition = alltrue([for each in var.client_names_europe : (length("${each}") < 9) ? true : false])
    # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  }
  validation {
    condition     = alltrue([for each in var.client_names_europe : can(regex("^[a-z0-9]+$", "${each}"))])
    error_message = "Please provide a valid value for variable client_names in lowercase with digits allowed"
  }
}

variable "client_names_unitedstates" {
  description = "Create Azure resources with these client names"
  type        = list(string)
  default     = ["client-anon"]
  validation {
    # https://spacelift.io/blog/how-to-use-terraform-variables
    # https://jeffbrown.tech/terraform-variables-validation/
    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char.
    # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
    # In consequence our client names cannot be longer than 8 char with the current naming scheme in our terraform code
    condition = alltrue([for each in var.client_names_unitedstates : (length("${each}") < 9) ? true : false])
    # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  }
  validation {
    condition     = alltrue([for each in var.client_names_unitedstates : can(regex("^[a-z0-9]+$", "${each}"))])
    error_message = "Please provide a valid value for variable client_names in lowercase with digits allowed"
  }
}

variable "client_names_with_enabled_app_gateways_europe" {
  description = "client names with dedicated app gateway, Europe region"
  type        = list(string)
  default     = ["client3"]
  validation {
    # https://spacelift.io/blog/how-to-use-terraform-variables
    # https://jeffbrown.tech/terraform-variables-validation/
    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char.
    # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
    # In consequence our client names cannot be longer than 8 char with the current naming scheme in our terraform code
    condition = alltrue([for each in var.client_names_with_enabled_app_gateways_europe : (length("${each}") < 9) ? true : false])
    # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  }
  validation {
    condition     = alltrue([for each in var.client_names_with_enabled_app_gateways_europe : can(regex("^[a-z0-9]+$", "${each}"))])
    error_message = "Please provide a valid value for variable client_names in lowercase with digits allowed"
  }
}

variable "client_names_with_enabled_app_gateways_unitedstates" {
  description = "client names with dedicated app gateway, United States region"
  type        = list(string)
  default     = ["client3"]
  validation {
    # https://spacelift.io/blog/how-to-use-terraform-variables
    # https://jeffbrown.tech/terraform-variables-validation/
    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char.
    # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
    # In consequence our client names cannot be longer than 8 char with the current naming scheme in our terraform code
    condition = alltrue([for each in var.client_names_with_enabled_app_gateways_unitedstates : (length("${each}") < 9) ? true : false])
    # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  }
  validation {
    condition     = alltrue([for each in var.client_names_with_enabled_app_gateways_unitedstates : can(regex("^[a-z0-9]+$", "${each}"))])
    error_message = "Please provide a valid value for variable client_names in lowercase with digits allowed"
  }
}

#####################################################################################################
# MONGODB ATLAS
# mongodb secrets setup as non-sensitive to see traces of mongoimport during the creation_time
#####################################################################################################
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
variable "mongodb_atlas_europe_region" {
  # https://www.mongodb.com/docs/atlas/reference/microsoft-azure/#microsoft-azure
  description = "MongoDB Atlas Cluster Region, must be a region for the provider given"
  type        = string
  default     = "EUROPE_NORTH"
  #default     = "EUROPE_WEST"
}
variable "mongodb_atlas_unitedstates_region" {
  # https://www.mongodb.com/docs/atlas/reference/microsoft-azure/#microsoft-azure
  description = "MongoDB Atlas Cluster Region, must be a region for the provider given"
  type        = string
  default     = "US_CENTRAL"
}
variable "mongodb_atlas_mongodbversion" {
  description = "The Major MongoDB Version"
  type        = string
  default     = "5.0" # Atlas supports the following MongoDB versions for M10+ clusters: 4.0, 4.2, 4.4, or 5.0
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
  default     = "appanalysis"
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

#################################
# Docker
#################################
variable "docker_registry" {
  description = "Docker Registry Server URL"
  type        = string
  default     = "https://enterpriseappanalysiscr.azurecr.io" # "EnterpriseAppAnalysisCR"
}
variable "docker_registry_username" {
  description = "Docker Registry Username"
  type        = string
  default     = "EnterpriseAppAnalysisCR"
  sensitive   = true
}

################################################
# Docker Image
# Enterprise App-Catalog aka omni-app-analysis:
################################################
variable "app_docker_image" {
  description = "Enterprise App-Catalog aka omni-app-analysis Docker Image"
  type        = string
  default     = "enterpriseappanalysiscr.azurecr.io/omni"
}
variable "app_docker_image_tag" {
  description = "Enterprise App-Catalog aka omni-app-analysis Docker Image Tag"
  type        = string
  default     = "3.0.2"
}

################################################
# Docker Image
# Enterprise Monitor Client (Prometheus exporter)
################################################
variable "prometheus_exporter_docker_image" {
  description = "Enterprise AppAnalysis Prometheus Exporter Docker Image"
  type        = string
  default     = "enterpriseappanalysiscr.azurecr.io/monitor-client"
}
variable "prometheus_exporter_docker_image_tag" {
  description = "Enterprise AppAnalysis Prometheus Exporter Docker Image Tag"
  type        = string
  default     = "1.0.1"
}

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
  default     = "aks-neeng" #"aks-computation-devtest" # "aks-computation-core"
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
  default     = "Enterprise"
  sensitive   = true
}
variable "secret_aks_kube_config_host_europe" {
  description = "aks_kube_config_host"
  type        = string
  sensitive   = false
  default     = "rg-sharedinfra-aks-neeng-b360a135.hcp.northeurope.azmk8s.io:443"
}
variable "secret_aks_kube_config_client_certificate_europe" {
  description = "aks_kube_config_client_certificate"
  type        = string
  sensitive   = false
  default     = "value"
}
variable "secret_aks_kube_config_client_key_europe" {
  description = "aks_kube_config_client_key"
  type        = string
  sensitive   = false
  default     = "value"
}
variable "secret_aks_kube_config_cluster_ca_certificate_europe" {
  description = "aks_kube_config_cluster_ca_certificate"
  type        = string
  sensitive   = false
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

##########################################################################################################################
# Key Vault Settings
# Vault Purge Protection: Disabled even on Production, since this needs to be fully automated via terraform lifecycle
##########################################################################################################################
# variable "vault_purge_protection_enabled" {
#   # (Optional) Once Purge Protection has been Enabled it's not possible to Disable it.
#   description = "purge_protection_enabled in azure key vaults"
#   type        = bool
#   default     = false # DO NOT enable this! once Purge Protection has been Enabled it's not possible to disable it
# }
# variable "vault_soft_delete_retention_days" {
#   # (Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days.
#   description = "purge_protection_enabled in azure key vaults"
#   type        = number
#   default     = null
# }


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