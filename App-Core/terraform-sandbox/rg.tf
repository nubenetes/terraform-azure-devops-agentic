resource "azurerm_resource_group" "appcore_rg" {
  name     = "rg-terraform-sandbox-<your_name>-dev"
  location = "northeurope"
}
