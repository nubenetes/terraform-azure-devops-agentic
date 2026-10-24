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
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
      # https://docs.microsoft.com/en-us/azure/developer/terraform/provider-version-history-azurerm
    }
    # Configure the Azure Active Directory Provider
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.25.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.0"
    }
  }
}





