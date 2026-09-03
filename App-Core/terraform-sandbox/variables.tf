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
  description = "A prefix for any dns based resources"
  type        = string
  default     = "appcore" # Alternatives: app, appcore, core, etc
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


variable "client_names" {
  description = "Create Azure resources with these client names"
  type        = list(any)
  default = ["client-anon",
  "client2"]
  # validation {
  #    # https://spacelift.io/blog/how-to-use-terraform-variables
  #    # https://jeffbrown.tech/terraform-variables-validation/
  #    # Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char
  #    condition     = alltrue([for each in var.client_names : (length("${each}") < 9) ? true:false])  # cannot be longer than 8 char with the current keyvault naming scheme in our terraform code
  #    error_message = "Please provide a valid value for variable client_names with a maximum length of than 8 chars"
  # }

}