###########################
# AzureRM
###########################
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {
  #subscription_id   = azurerm_client_config.current.subscription_id
  #tenant_id         = azurerm_client_config.current.tenant_id
}

###################################
# DNS ZONE AND DNS SUBDOMAINS
##################################
data "azurerm_dns_zone" "my_dns" {
  name                = azurerm_dns_zone.my_dns.name
  resource_group_name = azurerm_resource_group.sharedinfra_rg.name
}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

###########################
#  RG
###########################
data "azurerm_resource_group" "sharedinfra_rg" {
  name = azurerm_resource_group.sharedinfra_rg.name
}

