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
    #   version     = "~> 1.8.1"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.18.1"
    # }
  }
}

provider "azurerm" {
  features {}
}
