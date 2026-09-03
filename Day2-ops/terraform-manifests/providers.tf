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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }
    ansible = {
      # https://www.ansible.com/blog/providing-terraform-with-that-ansible-magic
      # https://www.ansible.com/blog/walking-on-clouds-with-ansible
      # https://ansible29.rssing.com/chan-30085529/latest.php
      # https://github.com/ansible/terraform-provider-ansible
      source  = "ansible/ansible"
      version = "~> 1.1.0"
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
  #region                     = "northeurope"
  features {
    # resource_group behavior managed via AzureRM v4 lifecycle rules
  }
}


# 2. Terraform Provider Block for AzureRM - North Europe
provider "azurerm" {
  alias           = "europe"
  subscription_id = var.azure_subscription_europe
  #region                     = "northeurope"
  skip_provider_registration = true # required to run azurerm_resource_provider_registration.aks_cluster
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
  #region                     = "centralus"
  skip_provider_registration = true # required to run azurerm_resource_provider_registration.aks_cluster
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    # resource_group behavior managed via AzureRM v4 lifecycle rules
  }
}

# 4. Terraform Provider Block for AzureAD
provider "azuread" {
  # NOTE: Environment Variables can also be used for Service Principal authentication
  # Terraform also supports authenticating via the Azure CLI too.
  # See official docs for more info: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
  # client_id     = "..."
  # client_secret = "..."
  # tenant_id     = "..."
  tenant_id = var.aad_tenant_id
}


provider "helm" {
  alias = "europe"
  debug = true # Debug indicates whether or not Helm is running in Debug mode.
  kubernetes {
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

  # private registry
  # registry {
  #   url = "oci://private.registry"
  #   username = "username"
  #   password = "password"
  # }
}


provider "helm" {
  alias = "us"
  debug = true # Debug indicates whether or not Helm is running in Debug mode.
  kubernetes {
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

  # private registry
  # registry {
  #   url = "oci://private.registry"
  #   username = "username"
  #   password = "password"
  # }
}

provider "kubectl" {
  alias                  = "europe"
  host                   = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
  cluster_ca_certificate = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
  load_config_file       = false
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

provider "kubectl" {
  alias                  = "us"
  host                   = local.deploy_United_States ? var.secret_aks_kube_config_host_unitedstates : null
  cluster_ca_certificate = local.deploy_United_States ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_unitedstates) : null
  load_config_file       = false
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


# https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/_examples/aks
# https://kubernetes.io/docs/tasks/administer-cluster/certificates/
provider "kubernetes" {
  alias                  = "europe"
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

provider "ansible" {
  alias                  = "europe"
  host                   = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
  cluster_ca_certificate = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
  load_config_file       = false
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
provider "ansible" {
  alias                  = "us"
  host                   = local.deploy_Europe ? var.secret_aks_kube_config_host_europe : null
  cluster_ca_certificate = local.deploy_Europe ? base64decode(var.secret_aks_kube_config_cluster_ca_certificate_europe) : null
  load_config_file       = false
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

############################################################################
# I did the following to get the AKS token:
# 1. We need to create the service account for AKS
# 2. Fetch the token
# We need the Kubernetes provider to create a service account
# https://github.com/gavinbunney/terraform-provider-kubectl/issues/35
############################################################################

# https://github.com/gavinbunney/terraform-provider-kubectl

# provider "kubectl" {
#   load_config_file = false
#   host = azurerm_kubernetes_cluster.REDACTED.kube_config.0.host
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.REDACTED.kube_config.0.cluster_ca_certificate)
#   token = yamldecode(azurerm_kubernetes_cluster.REDACTED.kube_config_raw).users[0].user.token
# }


# Add Data Source to Retrieve Azure AD Access Token for a Service Principal
# https://github.com/hashicorp/terraform-provider-azuread/issues/321
# https://learn.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/aad/app-aad-token
# The access token rotates quickly (between 5-60 minutes) it would cause unnecessary state diffs.
# resource "null_resource" "postgres_things" {
#   provisioner "local-exec" {
#     command = "./script.sh"
#   }

#   environment = {
#     TENANT_ID     = "[tenant_id]"
#     CLIENT_ID     = "[client_id]"
#     CLIENT_SECRET = "[client_secret]"
#   }
# }

# TOKEN="$(curl -i -X POST \
#   -d "client_id=${CLIENT_ID}" \
#   -d "client_secret=${CLIENT_ID}" \
#   -d "grant_type=client_credentials" \
#   -d "resource=https://ossrdbms-aad.database.windows.net" \
#   "https://login.microsoftonline.com/${TENANT_ID}/oauth2/token" \
#   | jq -r .access_token)"

# echo $TOKEN


# Service principal with working Azure Roles as tf context is unable to authenticate via kubernetes provider block but az aks get-credentials and kubectl get pods -n xy works
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1964
# Managed Clusters - List Cluster Admin Credentials https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/list-cluster-admin-credentials?tabs=HTTP
# Managed Clusters - List Cluster User Credentials https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/list-cluster-user-credentials?tabs=HTTP

# Fetching AKS Cluster credentials unfortunately does still not work. PR #20927 did NOT solve the issue
# https://github.com/hashicorp/terraform-provider-azurerm/issues/21183

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
# It is buggy because under it seems that it tries to fetch ALWAYS the Admin credentials even when the request is the USER credentials: kube_config versus kube_admin_config. This usecase was not implemented.
# Thanks. How will this data then be accessed? Will the limited permissions be provided by calling:
# data.azurerm_kubernetes_cluster.aks_provider_config.kube_config
# and the admin permissions by:
# data.azurerm_kubernetes_cluster.aks_provider_config.kube_admin_config ?
# How do you handle if the tf user context does not have the "Azure Kubernetes Service Cluster Admin Role"? Will the data structure be empty? Will the tf run fail or will it just ignore silently?

# Access and identity options for Azure Kubernetes Service (AKS):
# https://learn.microsoft.com/en-us/azure/aks/concepts-identity
