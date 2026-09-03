# Azure Location
variable "location" {
  type        = string
  description = "Azure Region where all these resources will be provisioned"
  default     = "northeurope"
}

#############
# RG Prefix
#############
variable "rg_prefix" {
  description = "The prefix which should be used for all rg resources"
  type        = string
  default     = "rg"
}

# Azure Environment Name
variable "environment" {
  type        = string
  description = "This variable defines the Environment"
  default     = "eng"
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
# Enterprise Product: Shared Infra
#################################
variable "Enterprise_product" {
  type        = string
  description = "This variable defines the product"
  default     = "sharedinfra-mdc"
}
