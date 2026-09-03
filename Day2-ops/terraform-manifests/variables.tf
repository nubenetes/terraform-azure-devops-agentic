
#################################
# Azure Subscription
#################################
variable "azure_subscription_unitedstates" {
  description = "The azure subscription ID with Terraform apply"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # Enterprise Example-DevOps-Subscription
}
variable "azure_subscription_europe" {
  description = "The azure subscription ID with Terraform apply"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000" # Enterprise Example-DevOps-Subscription
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
# RG Prefix
variable "rg_prefix" {
  description = "The prefix which should be used for all rg resources"
  type        = string
  default     = "rg"
}

#################################
# Azure Environment Name
#################################
variable "environment" {
  type        = string
  description = "This variable defines the Environment"
  #default = "eng"
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

#######################
# DNS
#######################
# variable "dns_parent_zone" {
#   description = "DNS Parent Zone"
#   type        = string
#   default     = "enterprise.com" # Don't change this
# }
# variable "dns_child_zone_eng" {
#   description = "DNS Child Zone"
#   type        = string
#   default     = "eng"
# }
# variable "dns_child_zone_pro" {
#   description = "DNS Child Zone"
#   type        = string
#   default     = "apps"
# }
# variable "dns_prefix" {
#   description = "A prefix for any dns based resources"
#   type        = string
#   default     = "si" # shared infra
# }

#################################
# Enterprise Product: Shared Infra
#################################
variable "Enterprise_product" {
  type        = string
  description = "This variable defines the product"
  default     = "day2ops"
}

#################################
# AKS
# Define Input Variables
# 1. Azure Location (CentralUS)
# 2. Azure Resource Group Name
# 3. Azure AKS Environment Name (Dev, QA, Prod)
#################################

# AKS Input Variables
variable "ssh_public_key" {
  #default = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

variable "secret_aks_kube_config_host_europe" {
  description = "aks_kube_config_host"
  type        = string
  sensitive   = true
  default     = "rg-sharedinfra-aks-neeng-b360a135.hcp.northeurope.azmk8s.io:443"
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

variable "secret_aks_kube_config_cluster_ca_certificate_unitedstates" {
  description = "aks_kube_config_cluster_ca_certificate"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "secret_azure_devops_sp" {
  description = "client_secret of the Service Principal that run this Azure DevOps Pipeline. Required by kubelogin in terraform kubernetes provider"
  type        = string
  sensitive   = true
  default     = "value"
}