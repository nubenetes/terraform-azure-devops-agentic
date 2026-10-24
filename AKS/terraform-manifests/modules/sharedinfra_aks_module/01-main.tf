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
removed {
  from = random_pet.aksrandom
  lifecycle {
    destroy = false
  }
}


# Documentation Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions
# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.rg_aks.location
  include_preview = false
}

removed {
  from = azurerm_resource_provider_registration.aks_cluster
  lifecycle {
    destroy = false
  }
}
