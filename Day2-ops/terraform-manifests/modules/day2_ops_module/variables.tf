#################################
# Azure Environment Name
#################################
variable "environment" {
  description = "This variable defines the Environment"
  type        = string
  default     = "eng"
}

#################################
# Enterprise Product: App-Core
#################################
variable "Enterprise_product" {
  description = "This variable defines the product"
  type        = string
  default     = "day2ops" # Alternatives: app, appcore, core, etc
}

#################################
# Azure DevOps Git Branch Name
#################################
variable "gitbranch" {
  description = "This variable defines the git branch name on Azure DevOps Repo"
  type        = string
  default     = "develop"
}

########################################
# Location Code
########################################
variable "location_code" {
  description = "Azure Region Code - Short name of location var"
  type        = string
  #default     = "ne"
}