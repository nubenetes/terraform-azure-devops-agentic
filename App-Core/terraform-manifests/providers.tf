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

#####################################################################################################################################################################
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-provider
# Configure the provider (Choose AKS)
# Before you can schedule any Kubernetes services using Terraform, you need to configure the Terraform Kubernetes provider.
# There are many ways to configure the Kubernetes provider. We recommend them in the following order (most recommended first, least recommended last):
# Use cloud-specific auth plugins (for example, eks get-token, az get-token, gcloud config)
# Use oauth2 token
# Use TLS certificate credentials
# Use kubeconfig file by setting both config_path and config_context
# Use username and password (HTTP Basic Authorization)
#
# We recommend using provider-specific data sources when convenient. terraform_remote_state is more flexible, but requires access to the whole Terraform state.
# Provision an AKS Cluster: https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks
#####################################################################################################################################################################

# https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/_examples/aks
# https://kubernetes.io/docs/tasks/administer-cluster/certificates/
# provider "kubernetes" {
#   alias                    = "europe"
#   host                     = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
#   client_certificate       = local.deploy_Europe ? base64decode(var.secret_aks_kube_admin_config_client_certificate_europe) : null
#   client_key               = local.deploy_Europe ? base64decode(var.secret_aks_kube_admin_config_client_key_europe) : null
#   cluster_ca_certificate   = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
# }

############################################################################################
# Certificate rotation in Azure Kubernetes Service (AKS)
# https://learn.microsoft.com/en-us/azure/aks/certificate-rotation
# Azure Kubernetes Service (AKS) uses certificates for authentication with many of its components.
# If you have a RBAC-enabled cluster built after March 2022, it's enabled with certificate auto-rotation.
# Periodically, you may need to rotate those certificates for security or policy reasons.
# For example, you may have a policy to rotate all your certificates every 90 days.
# Certificate auto-rotation will only be enabled by default for RBAC enabled AKS clusters.
############################################################################################

###########################################################################################################################
# AKS 1.24+ cluster you need to use kubelogin binary
# Provider errors when AKS is created in the same terraform #2017 https://github.com/hashicorp/terraform-provider-kubernetes/issues/2017
# https://www.danielstechblog.io/azure-kubernetes-service-using-kubernetes-credential-plugin-kubelogin-with-terraform/
###########################################################################################################################

#####################################################
# HelmDeploy@0 and Kubernetes@1 do not work with kubelogin #15802
# https://github.com/microsoft/azure-pipelines-tasks/issues/15802
#####################################################

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
# https://spacelift.io/blog/terraform-kubernetes-provider
# https://azure.github.io/kubelogin/cli/get-token.html
# https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins
# https://azure.github.io/kubelogin/concepts/exec-plugin.html
# https://azure.github.io/kubelogin/concepts/login-modes/sp.html
# https://discuss.hashicorp.com/t/aad-integrated-kubernetes-cluster-no-longer-able-to-use-kubernetes-provider-following-disabling-local-admin-account/33439
# Youtube: Kubelogin to connect to kubernetes https://www.youtube.com/watch?v=XFWphg4EYL0
# https://azure.github.io/kubelogin/cli/get-token.html
provider "kubernetes" {
  alias = "europe"
  #host                     = var.cluster_endpoint
  host                   = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
  cluster_ca_certificate = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
  # using kubelogin to get an AAD token for the cluster.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/usr/bin/kubelogin"
    args = [
      "get-token",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 00000000-0000-0000-0000-000000000000 in any environments.
      "--client-id",
      data.azuread_client_config.current.client_id,
      #data.azuread_service_principal.azure_devops_sp.application_id,
      #data.azurerm_client_config.current.application_id,
      "--client-secret",
      var.secret_azure_devops_sp,
      "--tenant-id",
      var.aad_tenant_id,
      "--login",
      "spn"
    ]
  }
}

# az login
# az account set --subscription 00000000-0000-0000-0000-000000000000
# az aks get-credentials --resource-group rg-sharedinfra-aks-neeng --name aks-neeng
# kubelogin convert-kubeconfig -l azurecli

# https://azure.github.io/kubelogin/index.html

provider "kubernetes" {
  alias                  = "us"
  host                   = local.deploy_United_States ? var.secret_aks_kube_config_host_unitedstates : null
  cluster_ca_certificate = local.deploy_United_States ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_unitedstates) : null
  # using kubelogin to get an AAD token for the cluster.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/usr/bin/kubelogin"
    args = [
      "get-token",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks_aad_server.application_id, # Note: The AAD server app ID of AKS Managed AAD is always 00000000-0000-0000-0000-000000000000 in any environments.
      "--client-id",
      data.azuread_client_config.current.client_id,
      #data.azuread_service_principal.azure_devops_sp.application_id,
      #data.azurerm_client_config.current.application_id,
      "--client-secret",
      var.secret_azure_devops_sp,
      "--tenant-id",
      var.aad_tenant_id,
      "--login",
      "spn"
    ]
  }
}

provider "null" {}