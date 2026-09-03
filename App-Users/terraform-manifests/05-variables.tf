
###################
# AAD Tenant ID
###################
variable "aad_tenant_id" {
  description = "This variable defines AAD Tenant ID"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  default     = "develop"
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
  description = "This nap defines the DNS Zone assigned to each environment"
  type        = map(any)
  default = {
    "client-anon" = "deng"
    "client-anon" = "deng"
    "dneuat"      = "deng"
    "dnepre"      = "deng"
    "dnepro"      = "deng"
    "dnedem"      = "deng"
    "dneres"      = "deng"
    "nedev"       = "eng"
    "neqa"        = "eng"
    "neuat"       = "eng"
    "nepre"       = "eng"
    "nepro"       = "apps"
    "nedem"       = "apps"
    "neres"       = "apps"
  }
}