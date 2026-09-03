# Create Outputs
# 1. Resource Group Location
# 2. Resource Group Id
# 3. Resource Group Name

# Resource Group Outputs
output "location" {
  value = azurerm_resource_group.rg_aks.location
}

output "resource_group_id" {
  value = azurerm_resource_group.rg_aks.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg_aks.name
}

# Azure AKS Versions Datasource
output "versions" {
  value = data.azurerm_kubernetes_service_versions.current.versions
}

output "latest_version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

output "name" {
  value = data.azurerm_kubernetes_cluster.current.name
}

output "network_profile" {
  value = data.azurerm_kubernetes_cluster.current.network_profile
}

# Azure AD Group Object Id
output "azure_ad_group_administrators_name" {
  value = azuread_group.aks_administrators.display_name
}
output "azure_ad_group_administrators_id" {
  value = azuread_group.aks_administrators.id
}
output "azure_ad_group_administrators_objectid" {
  value = azuread_group.aks_administrators.object_id
}

output "azure_ad_group_developers_name" {
  value = azuread_group.aks_developers.display_name
}
output "azure_ad_group_developers_id" {
  value = azuread_group.aks_developers.id
}
output "azure_ad_group_developers_objectid" {
  value = azuread_group.aks_developers.object_id
}

# Azure AKS Outputs

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

####################################
# data.azurerm_subscription
####################################
output "myAzureSubscription" {
  value = data.azurerm_client_config.current.subscription_id
}
output "myAzureTenantId" {
  value = data.azurerm_client_config.current.tenant_id
}
