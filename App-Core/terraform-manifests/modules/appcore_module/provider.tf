# https://www.hashicorp.com/blog/terraform-azurerm-3-0-brings-enhanced-azure-function-support
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-upgrade-guide

# Multi-Region - Deploy to Multiple Regions using terraform providers:
# https://towardsaws.com/multi-region-deployment-in-aws-with-terraform-35763efacff
# https://medium.com/inspiredbrilliance/provision-multi-region-multi-environment-infrastructure-with-terraform-a62398ff0214
# https://www.youtube.com/watch?v=9f-NrYZ5tQg

# 1. Terraform Settings Block
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

terraform {
  #required_version = ">= 1.9.0, < 2.0.0"  #"1.2.8"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = ">= 3.22"  #"3.20.0" #"3.21.1" #"3.15.0"
      # https://docs.microsoft.com/en-us/azure/developer/terraform/provider-version-history-azurerm
    }
    # Configure the Azure Active Directory Provider
    azuread = {
      source = "hashicorp/azuread"
      #version = ">= 2.28" #"2.28.1" #"~> 2.7.0"   #"2.26.1"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.4" #"~> 3.0"
    # }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      #version     = "~> 1.4" #"~> 0.9.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
