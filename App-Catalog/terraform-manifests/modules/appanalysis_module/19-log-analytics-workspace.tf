# Create Log Analytics Workspace

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/monitoring-log-analytics/main.tf
resource "azurerm_log_analytics_workspace" "App-Catalog" {
  for_each                        = toset(var.client_names)
  name                            = "log-law-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  resource_group_name             = azurerm_resource_group.App-Catalog_rg[each.key].name
  location                        = azurerm_resource_group.App-Catalog_rg[each.key].location
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
