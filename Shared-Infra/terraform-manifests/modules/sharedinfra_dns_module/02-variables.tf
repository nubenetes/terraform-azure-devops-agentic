# Azure Location
variable "location" {
  type        = string
  description = "Azure Region where all these resources will be provisioned"
  default     = "northeurope"
}
variable "location_code" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  default     = "ne"
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

###################
# AAD Tenant ID
###################
variable "aad_tenant_id" {
  type        = string
  description = "This variable defines AAD Tenant ID"
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

#################################
# Enterprise Product: Shared Infra
#################################
variable "Enterprise_product" {
  type        = string
  description = "This variable defines the product"
  default     = "sharedinfra"
}

#######################
# DNS
#######################
variable "dns_parent_zone" {
  description = "DNS Parent Zone"
  type        = string
  default     = "enterprise.com" #"enterprise.com" # Don't change this
}
variable "dns_child_zone" {
  description = "DNS Child Zone"
  type        = string
  default     = "eng"
}
variable "dns_prefix" {
  description = "A prefix for any dns based resources"
  type        = string
  default     = "si" # shared infra
}