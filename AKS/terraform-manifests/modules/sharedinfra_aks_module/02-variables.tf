# Define Input Variables
# 1. Azure Location (CentralUS)
# 2. Azure Resource Group Name
# 3. Azure AKS Environment Name (Dev, QA, Prod)

#################################
# Enterprise Product: AKS
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  #default     = "aks" # Alternatives: app, appcore, core, etc
}

#################################
# RG Prefix
#################################
variable "rg_prefix" {
  description = "The prefix which should be used for all rg resources"
  type        = string
  #default     = "rg"
}

# Azure Location
variable "location" {
  type        = string
  description = "Azure Region where all these resources will be provisioned"
  #default = "North Europe"
}
variable "location_code" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  #default     = "ne"
}

# Azure AKS Environment Name
variable "environment" {
  type        = string
  description = "This variable defines the Environment"
  #default = "dev"
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  #default     = "develop"
}

# AKS Input Variables

# SSH Public Key for Linux VMs
variable "ssh_public_key" {
  #default = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

#################################
# AKS
#################################
variable "kubernetes_version" {
  type        = string
  description = "This variable defines the kubernetes version in AKS"
}

#################################
# DNS
#################################
# variable "dns_zone_id" {
#   type = string
#   description = "The ID of the DNS Zone"
# }

#################################
# testing (temporary)
#################################
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

########################################
# AKS Users
########################################
variable "aks_administrators" {
  description = "List of Admins with access to AKS (cluster-admin role)"
  type        = list(string)
  default = [
    "cloud-admin@example.com",
    "cloud-admin@example.com",
  ]
}
variable "aks_developers" {
  description = "List of Developers with access to AKS (admin role to development namespaces)"
  type        = list(string)
  default = [
    "cloud-admin@example.com",
  ]
}

########################################
# Service Principals
########################################
variable "service_principals_with_aad_aks_cluster_admin_role" {
  description = "List of Service Principals with Cluster Admin Role to AKS"
  type        = list(string)
  default = [
    "sp-day2ops-Enterprise-devops",
  ]
}