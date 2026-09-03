###############################################################
# AzureRM
# https://github.com/hashicorp/terraform-provider-azurerm
###############################################################
# data "azurerm_subscription" "current" {
#   #subscription_id   = var.azure_subscription
# }

data "azurerm_client_config" "current" {
  #subscription_id   = azurerm_client_config.current.subscription_id
  #tenant_id         = azurerm_client_config.current.tenant_id
}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}
