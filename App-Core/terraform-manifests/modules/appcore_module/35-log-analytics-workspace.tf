# Create Log Analytics Workspace

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/monitoring-log-analytics/main.tf
# resource "azurerm_log_analytics_workspace" "appcore" {
#   name                                 = "log-law-${local.instance_name}-${each.value}"
#   resource_group_name                  = azurerm_resource_group.appcore_rg.name
#   location                             = azurerm_resource_group.appcore_rg.location
#   allow_resource_only_permissions      = true #(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to true.
#   local_authentication_disabled        = true #(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD. Defaults to false.
#   sku                                  = "PerGB2018"
#   retention_in_days                    = 30
#   #daily_quota_gb                      = 10 #(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted.
#   # cmk_for_query_forced               =  #(Optional) Is Customer Managed Storage mandatory for query management?
#   # internet_ingestion_enabled         =  #(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true.
#   # internet_query_enabled             = #(Optional) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true.
#   # reservation_capacity_in_gb_per_day = #(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000.
#   tags                                 = local.tags #(Optional) A mapping of tags to assign to the resource.
# }



resource "azurerm_log_analytics_workspace" "appcore_back" {
  name                            = "log-law-${var.Enterprise_product}-back-${local.instance_environment}"
  resource_group_name             = azurerm_resource_group.appcore_rg.name
  location                        = azurerm_resource_group.appcore_rg.location
  allow_resource_only_permissions = true #(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to true.
  local_authentication_disabled   = true #(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD. Defaults to false.
  sku                             = "PerGB2018"
  retention_in_days               = 30
  #daily_quota_gb                      = 10 #(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted.
  # cmk_for_query_forced               =  #(Optional) Is Customer Managed Storage mandatory for query management?
  # internet_ingestion_enabled         =  #(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true.
  # internet_query_enabled             = #(Optional) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true.
  # reservation_capacity_in_gb_per_day = #(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000.
  tags = local.tags #(Optional) A mapping of tags to assign to the resource.
}

resource "azurerm_log_analytics_workspace" "applink_cloud" {
  name                            = "log-law-applink-cloud-${local.instance_environment}"
  resource_group_name             = azurerm_resource_group.appcore_rg.name
  location                        = azurerm_resource_group.appcore_rg.location
  allow_resource_only_permissions = true #(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to true.
  local_authentication_disabled   = true #(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD. Defaults to false.
  sku                             = "PerGB2018"
  retention_in_days               = 30
  #daily_quota_gb                      = 10 #(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted.
  # cmk_for_query_forced               =  #(Optional) Is Customer Managed Storage mandatory for query management?
  # internet_ingestion_enabled         =  #(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true.
  # internet_query_enabled             = #(Optional) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true.
  # reservation_capacity_in_gb_per_day = #(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000.
  tags = local.tags #(Optional) A mapping of tags to assign to the resource.
}

resource "azurerm_log_analytics_workspace" "applink_onprem_myclient" {
  for_each                        = toset(var.client_names)
  name                            = "log-law-applink-onprem-${each.value}-${local.instance_environment}"
  resource_group_name             = azurerm_resource_group.appcore_rg.name
  location                        = azurerm_resource_group.appcore_rg.location
  allow_resource_only_permissions = true #(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace. Defaults to true.
  local_authentication_disabled   = true #(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD. Defaults to false.
  sku                             = "PerGB2018"
  retention_in_days               = 30
  #daily_quota_gb                      = 10 #(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted.
  # cmk_for_query_forced               =  #(Optional) Is Customer Managed Storage mandatory for query management?
  # internet_ingestion_enabled         =  #(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true.
  # internet_query_enabled             = #(Optional) Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true.
  # reservation_capacity_in_gb_per_day = #(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000.
  tags = local.tags #(Optional) A mapping of tags to assign to the resource.
}

# data "azurerm_log_analytics_workspace" "appcore_myclient" {
#   for_each            = toset(var.client_names)
#   name                = azurerm_log_analytics_workspace.appcore_myclient[eack.key].name
#   resource_group_name = azurerm_resource_group.appcore_rg.name
# }


# # https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-endpoint-overview
# resource "azurerm_monitor_data_collection_endpoint" "appcore_myclient" {
#   for_each                      = toset(var.client_names)
#   name                          = "mdce-${local.instance_name}-${each.value}"
#   resource_group_name           = azurerm_resource_group.appcore_rg.name
#   location                      = azurerm_resource_group.appcore_rg.location
#   kind                          = "Linux"
#   public_network_access_enabled = true
#   description                   = "monitor_data_collection_endpoint example"
#   tags                          = local.tags
# }


# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule
# resource "azurerm_log_analytics_solution" "appcore_myclient" {
#   for_each              = toset(var.client_names)
#   solution_name         = "WindowsEventEventForwarding-${local.instance_name}-${each.value}"
#   location              = azurerm_resource_group.appcore_rg.location
#   resource_group_name   = azurerm_resource_group.appcore_rg.name
#   workspace_resource_id = azurerm_log_analytics_workspace.appcore_myclient[each.key].id
#   workspace_name        = azurerm_log_analytics_workspace.appcore_myclient[each.key].name
#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/WindowsEventEventForwarding"
#     # Error: Code="InvalidParameter" Message="Solution product name cannot start with 'OMSGallery/' as it is reserved for Microsoft first party solutions.
#   }
# }

# resource "azurerm_monitor_data_collection_rule" "appcore_myclient" {
#   for_each            = toset(var.client_names)
#   name                = "mdcr-${local.instance_name}-${each.value}"
#   resource_group_name = azurerm_resource_group.appcore_rg.name
#   location            = azurerm_resource_group.appcore_rg.location

#   destinations {
#     log_analytics {
#       workspace_resource_id = azurerm_log_analytics_workspace.appcore_myclient[each.key].id
#       name                  = "test-destination-log"
#     }

#     azure_monitor_metrics {
#       name = "test-destination-metrics"
#     }
#   }

#   data_flow {
#     streams      = ["MIcrosoft-InsightsMetrics"]
#     destinations = ["test-destination-metrics"]
#   }

#   data_flow {
#     streams      = ["MIcrosoft-InsightsMetrics", "MIcrosoft-Syslog", "MIcrosoft-Perf"]
#     destinations = ["test-destination-log"]
#   }

#   data_sources {
#     syslog {
#       facility_names = ["*"]
#       log_levels     = ["*"]
#       name           = "test-datasource-syslog"
#     }

#     performance_counter {
#       streams                       = ["MIcrosoft-Perf", "MIcrosoft-InsightsMetrics"]
#       sampling_frequency_in_seconds = 10
#       counter_specifiers            = ["Processor(*)\\% Processor Time"]
#       name                          = "test-datasource-perfcounter"
#     }
#     extension {
#       streams            = ["MIcrosoft-WindowsEvent"]
#       input_data_sources = ["test-datasource-wineventlog"]
#       extension_name     = "test-extension-name"
#       extension_json = jsonencode({
#         a = 1
#         b = "hello"
#       })
#       name = "test-datasource-extension"
#     }
#   }

#   description = "data collection rule example"
#   tags = {
#     foo = "bar"
#   }
#   depends_on = [
#     azurerm_log_analytics_solution.appcore_myclient
#   ]
# }