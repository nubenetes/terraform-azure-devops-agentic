######################################
# Azure Subscription ID
######################################
variable "azure_subscription" {
  description = "This variable defines the Azure Subscription ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.azure_subscription))
    error_message = "The azure_subscription value must be a valid UUID."
  }
}

###################
# AAD Tenant ID
###################
variable "aad_tenant_id" {
  description = "This variable defines AAD Tenant ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.aad_tenant_id))
    error_message = "The aad_tenant_id value must be a valid UUID."
  }
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  default     = "develop"

  validation {
    condition     = contains(["develop", "main"], var.gitbranch)
    error_message = "The gitbranch value must be either 'develop' or 'main'."
  }
}

#################################
# Environment
#################################
variable "environment" {
  description = "This variable defines the target environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "uat", "pre", "pro", "dem", "res"], var.environment)
    error_message = "The environment must be one of: dev, qa, uat, pre, pro, dem, res."
  }
}

#################################
# Conditional Access Policy Flag
#################################
variable "enable_conditional_access_policy" {
  description = "Enable Zero-Trust MFA Conditional Access Policy for App-Core users"
  type        = bool
  default     = false
}

#################################
# Enterprise Product: App-Core
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "appcore-users" # Alternatives: app, appcore, core, etc
}

#################################
# DNS Zone per environment
#################################

variable "dns_zone_per_env" {
  description = "This map defines the DNS Zone assigned to each environment"
  type        = map(string)
  default = {
    "dnedev" = "deng"
    "dneqa"  = "deng"
    "dneuat" = "deng"
    "dnepre" = "deng"
    "dnepro" = "deng"
    "dnedem" = "deng"
    "dneres" = "deng"
    "nedev"  = "eng"
    "neqa"   = "eng"
    "neuat"  = "eng"
    "nepre"  = "eng"
    "nepro"  = "apps"
    "nedem"  = "apps"
    "neres"  = "apps"
  }
}