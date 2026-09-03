# Boilerplate:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf

# purging of Certificate "cert-appcore-pro" (Key Vault "https://kv-appcore-agw-pro.vault.azure.net/") :
# keyvault.BaseClient#PurgeDeletedCertificate: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error.
# Status=403 Code="Forbidden" Message="Operation \"purge\" is not allowed because purge protection is enabled for this vault. Key Vault service will automatically purge it after
# the retention period has passed. Vault: kv-appcore-agw-pro;location=northeurope" 2022-09-20T16:25:59

resource "azurerm_key_vault" "appcore_keyvault_agw" {
  name                = "kv-agw-cert-${local.instance_environment}" # "name" may only contain alphanumeric characters and dashes and must be between 3-24 char
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  #soft_delete_retention_days  = 7 # Required by azurerm_application_gateway.appcore_agw - trusted_root_certificate
  # The ability to turn off soft delete via the Azure Portal has been deprecated.
  # You can create a new key vault with soft delete off for a limited time using CLI / PowerShell / REST API.
  # The ability to create a key vault with soft delete disabled will be fully deprecated by the end of the year (2022).
  # It can be configured to between 7 to 90 days. Once it has been set, it cannot be changed or removed.
  tags                      = local.tags
  enable_rbac_authorization = true
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate
# Generating a new certificate
# Prod Environment: wildcard certificate
resource "azurerm_key_vault_certificate" "Enterprise_wildcard" {
  name         = "cert-${var.Enterprise_product}-${local.instance_environment}"
  key_vault_id = azurerm_key_vault.appcore_keyvault_agw.id
  certificate {
    contents = var.secret_appGatewayListenerSecure
    #password  = var.secret_certificate_passphrase
  }
  depends_on = [
    azurerm_key_vault.appcore_keyvault_agw,
    azurerm_role_assignment.appgateway_user_assigned_identity_keyvault_certs,
  ]
}


################################################
# Managed Identity (User Assigned)
################################################

resource "azurerm_user_assigned_identity" "appcore_agw" {
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  name                = "id-kv-${var.Enterprise_product}-agw-${local.instance_environment}"
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]

}
