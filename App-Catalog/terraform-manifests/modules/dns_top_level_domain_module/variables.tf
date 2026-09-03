#################################
# Azure Environment Name
#################################
variable "environment" {
  description = "This variable defines the Environment"
  type        = string
  default     = "dev"
}

#################################
# Enterprise Product: app-core
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "appanalysis" # Alternatives: qp, App-Core, core, etc
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  default     = "develop"
}

###########################
# DNS
###########################
variable "dns_zone_name_servers" {
  description = "dns zone name servers"
  type        = list(any)
}
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