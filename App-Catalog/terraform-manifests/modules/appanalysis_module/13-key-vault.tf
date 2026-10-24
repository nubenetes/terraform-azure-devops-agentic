# Boilerplate:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf


resource "azurerm_key_vault" "App-Catalog_keyvault" {
  for_each                   = toset(var.client_names)                                                                                  # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                       = "kv-${var.Enterprise_product}-${each.value}${local.gitbranch}${var.location_code}${local.env_generator}" # "name" may only contain alphanumeric characters and dashes and must be between 3-24 char
  location                   = local.location
  resource_group_name        = azurerm_resource_group.App-Catalog_rg[each.key].name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
  ]
}

resource "azurerm_role_assignment" "terraform_sp_keyvault_certs" {
  for_each             = toset(var.client_names)
  description          = "Key Vault Certificates Officer: RBAC role assignment to Terraform execution Service Principal"
  scope                = azurerm_key_vault.App-Catalog_keyvault[each.key].id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}


#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate
# Importing a PFX certificate (wildcard certificate):
resource "azurerm_key_vault_certificate" "Enterprise_wildcard" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name         = "cert-${each.value}-${local.instance_environment}"
  key_vault_id = azurerm_key_vault.App-Catalog_keyvault[each.key].id
  certificate {
    contents = var.secret_appGatewayListenerSecure
    password = ""
  }
  depends_on = [
    azurerm_key_vault.App-Catalog_keyvault,
    azurerm_role_assignment.appgateway_user_assigned_identity_keyvault_certs,
    azurerm_role_assignment.terraform_sp_keyvault_certs,
  ]
}


################################################
# Managed Identity (User Assigned)
################################################
resource "azurerm_user_assigned_identity" "App-Catalog_agw" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "id-kv-${var.Enterprise_product}-agw-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
  ]
}
