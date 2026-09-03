# Terraform - Deploy to Multiple Regions Using Providers https://www.youtube.com/watch?v=9f-NrYZ5tQg

# Best Practices for Provider Versions
# https://developer.hashicorp.com/terraform/language/providers/requirements
# https://developer.hashicorp.com/terraform/language/expressions/version-constraints
# A module intended to be used as the root of a configuration — that is, as the directory where you'd run terraform apply — should also specify the maximum provider version it is intended to work with,
# to avoid accidental upgrades to incompatible new versions. The ~> operator is a convenient shorthand for allowing the rightmost component of a version to increment.

terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
      # Due to the fast-moving nature of AKS, we recommend using the latest version of the Azure Provider when using AKS
      # https://docs.microsoft.com/en-us/azure/developer/terraform/provider-version-history-azurerm
    }
    # Configure the Azure Active Directory Provider
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
      # 2.34.0 issue found: https://github.com/hashicorp/terraform-provider-azuread/issues/1017
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
  }
  # Terraform State Storage to Azure Storage Container
  # https://www.terraform.io/language/settings/backends/configuration
  # https://www.terraform.io/language/settings/backends/azurerm
  # Terraform 1.1 and 1.2 supported a feature-flag to allow enabling/disabling the use of Microsoft Graph (and MSAL) rather than Azure Active Directory Graph (and ADAL)
  # - however this flag has since been removed in Terraform 1.3. Microsoft Graph (and MSAL) are now enabled by default and Azure Active Directory Graph (and ADAL) can no longer be used.
  backend "azurerm" {
    #resource_group_name   = "rg-terraform-storage-dev"
    #storage_account_name  = "sttfstateEnterprisedev"
    #container_name        = "citfstatefilesdev"
    #key                   = "terraform-custom-.tfstate"
    #region                = "northeurope"
  }
}



# 1. Terraform Provider Block for AzureRM with Default Enterprise Infrastructure Subscription
# https://samcogan.com/deploying-to-multiple-azure-subscriptions-with-terraform/
provider "azurerm" {
  alias           = "manualinfra"
  subscription_id = "00000000-0000-0000-0000-000000000000" # Enterprise Infrastructure Subscription
  #region            = "northeurope"
  features {
    # resource_group behavior managed via AzureRM v4 lifecycle rules
  }
}



# 2. Terraform Provider Block for AzureRM - North Europe
provider "azurerm" {
  alias           = "europe"
  subscription_id = var.azure_subscription_europe
  #region = "northeurope"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    # resource_group behavior managed via AzureRM v4 lifecycle rules
  }
}


# 3. Terraform Provider Block for AzureRM - Central US
provider "azurerm" {
  alias           = "us"
  subscription_id = var.azure_subscription_unitedstates
  #region = "centralus"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    # resource_group behavior managed via AzureRM v4 lifecycle rules
  }
}

provider "mongodbatlas" {
  alias = "europe"
  #region      = "EUROPE_NORTH"
  public_key  = var.secret_mongodb_atlas_public_key
  private_key = var.secret_mongodb_atlas_private_key
}

provider "mongodbatlas" {
  alias = "us"
  #region      = "US_CENTRAL"
  public_key  = var.secret_mongodb_atlas_public_key
  private_key = var.secret_mongodb_atlas_private_key
}

# 3. Terraform Provider Block for AzureAD
provider "azuread" {
  # NOTE: Environment Variables can also be used for Service Principal authentication
  # Terraform also supports authenticating via the Azure CLI too.
  # See official docs for more info: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
  # client_id     = "..."
  # client_secret = "..."
  # tenant_id     = "..."
  tenant_id = var.aad_tenant_id
}

# https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/_examples/aks
# https://kubernetes.io/docs/tasks/administer-cluster/certificates/
provider "kubernetes" {
  alias                  = "europe"
  host                   = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
  client_certificate     = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_client_certificate_europe) : null
  client_key             = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_client_key_europe) : null
  cluster_ca_certificate = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
}

provider "kubernetes" {
  alias                  = "us"
  host                   = local.deploy_United_States ? var.secret_aks_kube_config_host_unitedstates : null
  client_certificate     = local.deploy_United_States ? base64decode(var.secret_aks_kube_config_client_certificate_unitedstates) : null
  client_key             = local.deploy_United_States ? base64decode(var.secret_aks_kube_config_client_key_unitedstates) : null
  cluster_ca_certificate = local.deploy_United_States ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_unitedstates) : null
}
