###########################
# AzureRM
###########################
#data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

##########################################
# azuread_application_published_app_ids
##########################################
// Look up an app ID for a resource/service
// https://github.com/hashicorp/terraform-provider-azuread/issues/250
//
// https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
//    This data source uses an unofficial source of application IDs, as there is currently no available official indexed source for applications or APIs published by Microsoft:
//    https://github.com/manicminer/hamilton/blob/main/environments/published.go

// https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/resources/service_principal.md

data "azuread_application_published_app_ids" "well_known" {}

##################################################
# Data Source: azurerm_kubernetes_cluster
##################################################
data "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  resource_group_name = local.aks_resource_group_name
}


##################################################
# Data Source: azuread_group.aks_developers
##################################################
data "azuread_group" "aks_developers" {
  display_name     = local.aad_group_aks_developers_name
  security_enabled = true
}

########################################################################################################################################
# data source for OAuthPermissions and/or Azure Common APIs
# azuread_application_published_app_ids
# Look up an app ID for a resource/service
# https://github.com/hashicorp/terraform-provider-azuread/issues/250
#
# https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
#    This data source uses an unofficial source of application IDs, as there is currently no available official indexed source for applications or APIs published by Microsoft:
#    https://github.com/manicminer/hamilton/blob/main/environments/published.go
#
# https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/resources/service_principal.md
########################################################################################################################################
resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
  # (Optional) When true, any existing service principal linked to the same application will be automatically imported.
  # When false, an import error will be raised for any pre-existing service principal.
}



##################################################################
# kv-wildcards-Enterprise-com in Enterprise Infrastructure Subscription
##################################################################
data "azurerm_key_vault" "wildcards_Enterprise_com" {
  provider = azurerm.manualinfra
  # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
  name                = "kv-wildcards-Enterprise-com"
  resource_group_name = "CertificatesResourceGroup"
}

data "azurerm_key_vault_certificate" "wildcards_Enterprise_com" {
  provider = azurerm.manualinfra
  # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
  name         = "cert-wildcard-Enterprise-${local.dns_child_zone}"
  key_vault_id = data.azurerm_key_vault.wildcards_Enterprise_com.id
}

# data "azurerm_key_vault_secret" "wildcards_Enterprise_com_deng" {
#   provider     = azurerm.manualinfra
#     # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
#   name         = "cert-wildcard-deng-Enterprise-com00000000-0000-0000-0000-000000000000"
#   key_vault_id = data.azurerm_key_vault.wildcards_Enterprise_com.id
# }

data "azurerm_key_vault_secret" "wildcards_Enterprise_com" {
  provider = azurerm.manualinfra
  # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
  for_each     = toset(data.azurerm_key_vault_secrets.wildcards_Enterprise_com.names)
  name         = each.key
  key_vault_id = data.azurerm_key_vault.wildcards_Enterprise_com.id
}

data "azurerm_key_vault_secrets" "wildcards_Enterprise_com" {
  provider = azurerm.manualinfra
  # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
  key_vault_id = data.azurerm_key_vault.wildcards_Enterprise_com.id
}
