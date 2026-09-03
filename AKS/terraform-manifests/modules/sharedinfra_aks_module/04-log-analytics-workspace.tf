# Create Log Analytics Workspace

# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/monitoring-log-analytics/main.tf
resource "azurerm_log_analytics_workspace" "aks_cluster" {
  name                = "${azurerm_resource_group.rg_aks.name}-law"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  #daily_quota_gb      = 10 #(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted.
}

# Azure Monitor Insights overview
# https://learn.microsoft.com/en-us/azure/azure-monitor/insights/insights-overview

# resource "azurerm_log_analytics_solution" "aks_cluster_containers" {
#   solution_name         = "Containers"
#   location              = azurerm_resource_group.rg_aks.location
#   resource_group_name   = azurerm_resource_group.rg_aks.name  
#   workspace_resource_id = azurerm_log_analytics_workspace.aks_cluster.id
#   workspace_name        = azurerm_log_analytics_workspace.aks_cluster.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/Containers"
#   }
# }

# https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
resource "azurerm_log_analytics_solution" "aks_cluster_container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg_aks.location
  resource_group_name   = azurerm_resource_group.rg_aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_cluster.id
  workspace_name        = azurerm_log_analytics_workspace.aks_cluster.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
