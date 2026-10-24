terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    # mongodbatlas = {
    #   source      = "mongodb/mongodbatlas"
    #   version     = "~> 1.25.0"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.32.0"
    # }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}
