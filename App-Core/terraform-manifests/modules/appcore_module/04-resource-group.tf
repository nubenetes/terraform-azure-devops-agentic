

resource "azurerm_resource_group" "appcore_rg" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}
