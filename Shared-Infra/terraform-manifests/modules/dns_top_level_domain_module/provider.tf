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
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}





