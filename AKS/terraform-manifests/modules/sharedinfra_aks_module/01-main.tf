###########################
# AzureRM
###########################
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

###########################
#  RG
###########################
# data "azurerm_resource_group" "sharedinfra_rg" {
#   name              = azurerm_resource_group.rg_aks.name
# }

#############################################################
# Terraform Resource Block: Define a Random Pet Resource
#############################################################
resource "random_pet" "aksrandom" {
}


# Documentation Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions
# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.rg_aks.location
  include_preview = false
}

####################################################################################################
# Required by Kubernetes Provider providers.tf
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
###################################################################################################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster
# Use this data source to access information about an existing Managed Kubernetes Cluster (AKS)
data "azurerm_kubernetes_cluster" "current" {
  name                = azurerm_kubernetes_cluster.aks_cluster.name
  resource_group_name = azurerm_resource_group.rg_aks.name
}

######################################################################################################################################################################
# azurerm_resource_provider_registration to enable PREVIEW features
# Error: A resource with the ID "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.ContainerService" already exists
# - to be managed via Terraform this resource needs to be imported into the State.
# Please see the resource documentation for "azurerm_resource_provider_registration" for more information.
#
# Azure Portal -> Enterprise Example-DevOps-Subscription -> Resource Providers -> Microsoft.ContainerService -> click on 'Unregister' -> Error unregistering resource provider
# Workaround: terraform import azurerm_resource_provider_registration.example /subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.ContainerService
######################################################################################################################################################################
resource "azurerm_resource_provider_registration" "aks_cluster" {
  name = "Microsoft.ContainerService"
  # feature {
  #   # To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true.
  #   # This requires that the Preview Feature Microsoft.ContainerService/EnableWorkloadIdentityPreview is enabled and the Resource Provider is re-registered
  #   name       = "EnableWorkloadIdentityPreview"
  #   registered = true
  # }
  # feature {
  #   # azure_active_directory_role_based_access_control
  #   # This requires that the Preview Feature Microsoft.ContainerService/AKS-PrometheusAddonPreview is enabled, see the documentation for more information.
  #   name       = "AKS-PrometheusAddonPreview"
  #   registered = true
  # }
  feature {
    # api_server_access_profile
    # This requires that the Preview Feature Microsoft.ContainerService/EnableAPIServerVnetIntegrationPreview is enabled and the Resource Provider is re-registered
    name       = "EnableAPIServerVnetIntegrationPreview"
    registered = true
  }
}
