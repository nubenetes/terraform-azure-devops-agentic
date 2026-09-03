####################################
# Create Outputs
####################################

####################################
# Resource Group
####################################
output "myResourceGroup" {
  value = local.resource_group_name
}

####################################
# data.azurerm_client_config
####################################
output "myAzureSubscription" {
  value = data.azurerm_client_config.current.subscription_id
}
output "myAzureTenantId" {
  value = data.azurerm_client_config.current.tenant_id
}

####################################
# DNS
####################################
output "dns_zone" {
  value = local.dns_zone
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.my_dns.name_servers
}

output "dns_zone_id" {
  value = data.azurerm_dns_zone.my_dns.id
}

####################################
# data.azurerm_subscription
####################################
output "myAzureSubscription_id" {
  value = data.azurerm_subscription.current.id #  The ID of the subscription.
}
output "myAzureSubscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}
output "myAzureSubscription_tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
output "myAzureSubscription_tags" {
  value = data.azurerm_subscription.current.tags
}
output "myAzureSubscription_state" {
  value = data.azurerm_subscription.current.state # The subscription state. Possible values are Enabled, Warned, PastDue, Disabled, and Deleted.
}
output "myAzureSubscription_location_placement_id" {
  value = data.azurerm_subscription.current.location_placement_id # The subscription location placement ID.
}
output "myAzureSubscription_quota_id" {
  value = data.azurerm_subscription.current.quota_id # The subscription quota ID.
}
output "myAzureSubscription_spending_limit" {
  value = data.azurerm_subscription.current.spending_limit # The subscription spending limit. 
}

####################################
# Enterprise 
####################################
output "Enterprise_product" {
  value = var.Enterprise_product
}

#################
# Azure AD
#################
# output "azure_ad_application_key_id" {
#   value = azuread_application_password.web_app_resource_provider.key_id 
# }
# output "azure_ad_application_password" {
#   value = azuread_application_password.web_app_resource_provider.value 
#   sensitive = true
# }

#############################
# gitbranch
#############################
output "gitbranch" {
  value = local.gitbranch
}

