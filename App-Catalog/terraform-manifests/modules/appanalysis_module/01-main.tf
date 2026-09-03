################################
# AzureRM
################################
data "azurerm_client_config" "current" {
  #subscription_id   = azurerm_client_config.current.subscription_id
  #tenant_id         = azurerm_client_config.current.tenant_id
}

data "azurerm_subscription" "current" {}

##########################################
# AzureAD
##########################################

data "azuread_client_config" "current" {}

# Look up an app ID for a resource/service
# https://github.com/hashicorp/terraform-provider-azuread/issues/250
data "azuread_application_published_app_ids" "well_known" {}

###########################
# Randon UUID 
# The following example shows how to generate a unique name for an Azure Resource Group.
###########################
resource "random_password" "test_user1" {
  length      = 10
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = false
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "random_password" "test_admin" {
  length      = 14
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = false
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

