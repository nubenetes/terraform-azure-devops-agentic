
resource "azurerm_application_insights" "appcore_back" {
  #for_each            = toset(var.client_names)
  #name                = "appinsights-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  name                = "appinsights-${var.Enterprise_product}-back-${local.instance_environment}"
  location            = azurerm_resource_group.appcore_rg.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  workspace_id        = azurerm_log_analytics_workspace.appcore_back.id
  application_type    = "java"
}

resource "azurerm_application_insights" "applink_cloud" {
  #for_each            = toset(var.client_names)
  #name                = "appinsights-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  name                = "appinsights-applink-cloud-${local.instance_environment}"
  location            = azurerm_resource_group.appcore_rg.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  workspace_id        = azurerm_log_analytics_workspace.applink_cloud.id
  application_type    = "java"
}

resource "azurerm_application_insights" "applink_onprem_myclient" {
  for_each            = toset(var.client_names)
  name                = "appinsights-applink-onprem-${each.value}-${local.instance_environment}"
  location            = azurerm_resource_group.appcore_rg.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  workspace_id        = azurerm_log_analytics_workspace.applink_onprem_myclient[each.key].id
  application_type    = "java"
}

# output "application_insights_instrumentation_key" {
#   #value = values(azurerm_application_insights.appcore_myclient)[*].instrumentation_key
#   value = azurerm_application_insights.appcore_back.instrumentation_key
# }

# output "application_insights_connection_string" {
#   value = azurerm_application_insights.appcore_back.connection_string
# }

# output "application_insights_app_id" {
#   value = azurerm_application_insights.appcore_back.app_id
# }