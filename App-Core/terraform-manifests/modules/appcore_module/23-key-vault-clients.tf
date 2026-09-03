# Boilerplate:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf

resource "azurerm_key_vault" "appcore_keyvault_myclient" {
  for_each                  = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                      = "kv-${each.value}-${local.appcore_dns_name}"
  location                  = local.location
  resource_group_name       = azurerm_resource_group.appcore_rg.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  tags                      = local.tags
  enable_rbac_authorization = false
  #enabled_for_template_deployment = true
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}
resource "azurerm_key_vault_access_policy" "azure_devops_pipeline" {
  for_each     = toset(var.client_names)
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id # Service Principal of azure devops pipeline
  key_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "Update",
  ]
  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Recover",
    "Purge",
    "Restore",
  ]
  certificate_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "GetIssuers",
    "DeleteIssuers",
    "Recover",
    "Restore",
    "Purge",
    "Update",
    "Import",
  ]
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
  ]
}
resource "azurerm_key_vault_access_policy" "cloud_administrators" {
  for_each     = toset(var.client_names)
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.aad_administrators_group # AAD_Administrators Security Group
  key_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "Update",
  ]
  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Recover",
    "Purge",
    "Restore",
  ]
  certificate_permissions = [
    "Get",
    "Create",
    "List",
    "Delete",
    "GetIssuers",
    "DeleteIssuers",
    "Recover",
    "Restore",
    "Purge",
    "Update",
    "Import",
  ]
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
  ]
}



#################################################################
# AAD DEVELOPERS GROUP - Key Vault Access Policy
#################################################################
resource "azurerm_key_vault_access_policy" "aad_developers_group" {
  for_each                = toset(var.client_names)
  key_vault_id            = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.aad_developers_group
  key_permissions         = var.vault_access_policy_aad_developers_group_key_permissions
  secret_permissions      = var.vault_access_policy_aad_developers_group_secret_permissions
  certificate_permissions = var.vault_access_policy_aad_developers_group_certificate_permissions
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
  ]
}

####################################################################################################################################################
# Key Vault authentication options
# https://learn.microsoft.com/en-us/azure/key-vault/general/security-features#key-vault-authentication-options
#
# When you create a key vault in an Azure subscription, it's automatically associated with the Azure AD tenant of the subscription.
# All callers in both planes must register in this tenant and authenticate to access the key vault. In both cases, applications
# can access Key Vault in three ways:
#
# Application-only: The application represents a service principal or managed identity. This identity is the most common scenario for applications that
# periodically need to access certificates, keys, or secrets from the key vault. For this scenario to work, the objectId of the application must be
# specified in the access policy and the applicationId must not be specified or must be null.
#
# User-only: The user accesses the key vault from any application registered in the tenant. Examples of this type of access include Azure PowerShell and
# the Azure portal. For this scenario to work, the objectId of the user must be specified in the access policy and the applicationId must not be specified
# or must be null.
#
# Application-plus-user (sometimes referred as compound identity): The user is required to access the key vault from a specific application and the application
# must use the on-behalf-of authentication (OBO) flow to impersonate the user. For this scenario to work, both applicationId and objectId must be specified
# in the access policy. The applicationId identifies the required application and the objectId identifies the user. Currently, this option isn't available
# for data plane Azure RBAC.
####################################################################################################################################################

####################################################################################################################################################
# App-Link Cloud API (azuread_application.applink_cloud_api) access to each client's key vault with Vault Access Policy:
# - OAUTH 2.0 OBO-Flow (Delegated-Permissions) with "user_impersonation" claim (OAuth 2.0 permission scope)
# - No Compound Identity (aka application-plus-user)
#
# Requires:
# - azuread_application.applink_cloud_api.api.oauth2_permission_scope.value = "user_impersonation"
###################################################################################################################################################
resource "azurerm_key_vault_access_policy" "applink_cloud" {
  for_each     = toset(var.client_names)
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id    = azuread_service_principal.applink_cloud_api.application_tenant_id
  object_id    = azuread_service_principal.applink_cloud_api.object_id
  certificate_permissions = [
    "Get",
    "List",
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
  ]
  key_permissions = [
    "Get",
    "List",
  ]
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_key_vault_secret.database_myclient,
    azurerm_key_vault_secret.fileshare_myclient,
    azurerm_key_vault_secret.mkey_myclient,
    azurerm_key_vault_secret.storageaccount_myclient,
  ]
}


############################################################################
# Service Principal used by Azure DevOps App-Link pipeline
############################################################################
resource "azurerm_key_vault_access_policy" "sp_applink" {
  for_each     = toset(var.client_names)
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.sp_app_link_object_id
  # certificate_permissions = [
  #   "Get",
  #   "List",
  # ]
  secret_permissions = [
    "Get",
    "List",
  ]
  # key_permissions = [
  #   "Get",
  #   "List",
  # ]
}

#################################################################################################################################################################################
# App-Core Backend API (azuread_application.appcore_back_api) access to each client's key vault with Vault Access Policy:
# - OAUTH 2.0 OBO-Flow (Delegated-Permissions) with "user_impersonation" claim (OAuth 2.0 permission scope)
# - COMPOUND IDENTITY (aka application-plus-user)
#
# https://github.com/hashicorp/terraform-provider-azurerm/issues/6021
# https://docs.microsoft.com/en-us/azure/developer/terraform/provider-version-history-azurerm
# If you specify object_id and application_id you get a compound identity permission. This is correct behaviour according to the docs.
# object_id:      (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
#                  The object ID must be unique for the list of access policies. Changing this forces a new resource to be created.
# application_id  (Optional) The object ID of an Application in Azure Active Directory.
#
# Requires:
# - azuread_application.appcore_back_api.api.oauth2_permission_scope.value = "user_impersonation"
# - app_role defined in azuread_application.appcore_back_api.app_role ("Admin" & "Viewer")
#################################################################################################################################################################################
resource "azurerm_key_vault_access_policy" "compound_identity_appcore_back_api_app_role_viewer" {
  for_each       = toset(var.client_names)
  key_vault_id   = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id      = azuread_service_principal.appcore_back_api.application_tenant_id
  object_id      = azuread_group.appcore_user_role[each.key].object_id # Security Principal Group (object_id)
  application_id = azuread_service_principal.appcore_back_api.application_id
  # Application ID of the client making request on behalf of a principal
  key_permissions         = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions
  secret_permissions      = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions
  certificate_permissions = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_key_vault_secret.database_myclient,
    azurerm_key_vault_secret.fileshare_myclient,
    azurerm_key_vault_secret.mkey_myclient,
    azurerm_key_vault_secret.storageaccount_myclient,
  ]
}

resource "azurerm_key_vault_access_policy" "compound_identity_appcore_back_api_app_role_admin" {
  for_each       = toset(var.client_names)
  key_vault_id   = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  tenant_id      = azuread_service_principal.appcore_back_api.application_tenant_id
  object_id      = azuread_group.appcore_admin_role[each.key].object_id # Security Principal Group (object_id)
  application_id = azuread_service_principal.appcore_back_api.application_id
  # Application ID of the client making request on behalf of a principal
  key_permissions         = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions
  secret_permissions      = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions
  certificate_permissions = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_key_vault_secret.database_myclient,
    azurerm_key_vault_secret.fileshare_myclient,
    azurerm_key_vault_secret.mkey_myclient,
    azurerm_key_vault_secret.storageaccount_myclient,
  ]
}


###########################################
# Secrets
###########################################

resource "azurerm_key_vault_secret" "database_myclient" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-db" # Deployed Database Name in mongodb cluster is "modb-${var.Enterprise_product}-${each.value}"
  #value        = mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv
  value        = replace(join("/", [mongodbatlas_advanced_cluster.cluster.connection_strings.0.standard_srv, "modb-${var.Enterprise_product}-${each.value}"]), "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
  content_type = "ConnectionString"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    #mongodbatlas_advanced_cluster.cluster,
  ]
}



###########################################################################################################################
# TEMPORARY WORKAROUND !!
# RESOURCE CLONED FROM PREVIOUS RESOURCE !
# App Code should not hardcode the names of Azure Infra Resources
# Instead, the names of Azure Infra Resources should be treated as docker variables
###########################################################################
resource "azurerm_key_vault_secret" "database_legacy_myclient" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-applink-db" # Deployed Database Name in mongodb cluster is "modb-${var.Enterprise_product}-${each.value}"
  #value        = mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv
  value        = replace(join("/", [mongodbatlas_advanced_cluster.cluster.connection_strings.0.standard_srv, "modb-${var.Enterprise_product}-${each.value}"]), "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
  content_type = "ConnectionString"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    #mongodbatlas_advanced_cluster.cluster,
  ]
}
#########################################################################################################################


resource "azurerm_key_vault_secret" "documents_myclient" {
  for_each     = toset(var.client_names)
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-co"
  value        = azurerm_storage_container.appcore_myclient[each.key].name
  content_type = "name"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    mongodbatlas_advanced_cluster.cluster,
  ]
}



resource "azurerm_key_vault_secret" "fileshare_myclient" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-fs"                                                         # Deployed FS Name is "fs-${var.Enterprise_product}-${each.value}-${var.environment}"
  value        = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}" #azurerm_storage_share.fs_client[each.key].name
  content_type = "name"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_storage_share.fs_client,
  ]
}

resource "azurerm_key_vault_secret" "mkey_myclient" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-mkey" # secret master key (key of the storage-account)
  value        = azurerm_storage_account.appcore.primary_access_key
  content_type = "name"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_storage_account.appcore,
  ]
}

resource "azurerm_key_vault_secret" "storageaccount_myclient" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  key_vault_id = azurerm_key_vault.appcore_keyvault_myclient[each.key].id
  name         = "${each.value}-sa" # Deployed SA Name is "${var.storage_prefix}${local.env_generator}"
  value        = azurerm_storage_account.appcore.name
  content_type = "name"
  depends_on = [
    azurerm_key_vault.appcore_keyvault_myclient,
    azurerm_key_vault_access_policy.azure_devops_pipeline,
    azurerm_storage_account.appcore,
  ]
}
