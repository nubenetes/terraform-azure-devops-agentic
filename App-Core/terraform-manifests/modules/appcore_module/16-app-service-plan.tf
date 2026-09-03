# Boilerplates:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/app-service

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app

###################################
# SERVICE PLAN
##################################

resource "azurerm_service_plan" "appcore_service_plan" {
  name                = "plan-${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.appcore_rg.name
  location            = local.location
  os_type             = "Linux"
  sku_name            = var.plan_sku
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}
