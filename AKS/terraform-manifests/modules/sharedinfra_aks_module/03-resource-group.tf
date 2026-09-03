# Terraform Resource to Create Azure Resource Group with Input Variables defined in variables.tf
resource "azurerm_resource_group" "rg_aks" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    environment = local.environment
  }
}



