# Boilerplate:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf

# https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs
# Azure Application Gateway supports integration with Key Vault for server certificates that are attached to HTTPS-enabled listeners.
# This support is limited to the v2 SKU of Application Gateway.
#
# Provide a reference to an existing Key Vault certificate or secret when you create a HTTPS-enabled listener.
# After Application Gateway is configured to use Key Vault certificates, its instances retrieve the certificate from Key Vault and install them locally for TLS termination.
# The instances poll Key Vault at four-hour intervals to retrieve a renewed version of the certificate, if it exists.
# If an updated certificate is found, the TLS/SSL certificate that's currently associated with the HTTPS listener is automatically rotated.
#
# Application Gateway uses a secret identifier in Key Vault to reference the certificates. For Azure PowerShell, the Azure CLI, or Azure Resource Manager,
# we strongly recommend that you use a secret identifier that doesn't specify a version. This way, Application Gateway will automatically rotate the certificate
# if a newer version is available in your Key Vault. An example of a secret URI without a version is https://myvault.vault.azure.net/secrets/mysecret/.
#
# Delegate user-assigned managed identity to Key Vault. Define access policies to use the user-assigned managed identity with your Key Vault:
# - If you're using the permission model Vault access policy: Select Access Policies, select + Add Access Policy, select Get for Secret permissions,
#   and choose your user-assigned managed identity for Select principal. Then select Save.
# - If you're using Azure role-based access control follow the article Assign a managed identity access to a resource and assign the user-assigned
#   managed identity the Key Vault Secrets User role to the Azure Key Vault.
#   https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/howto-assign-access-portal
#
# Verify Firewall Permissions to Key Vault
# As of January 1, 2000, Key Vault recognizes Application Gateway as a trusted service by leveraging User Managed Identities for authentication to Azure Key Vault.
# With the use of service endpoints and enabling the trusted services option for Key Vault's firewall, you can build a secure network boundary in Azure.
# You can deny access to traffic from all networks (including internet traffic) to Key Vault but still make Key Vault accessible for an Application Gateway resource
# under your subscription.
#
# Key Vault Azure role-based access control permission model
# Application Gateway supports certificates referenced in Key Vault via the Role-based access control permission model. The first few steps to reference the
# Key Vault must be completed via ARM template, Bicep, CLI, or PowerShell.
# Specifying Azure Key Vault certificates that are subject to the role-based access control permission model is not supported via the portal.
# In this example, we’ll use PowerShell to reference a new Key Vault secret.
#
# # Get the Application Gateway we want to modify
# $appgw = Get-AzApplicationGateway -Name MyApplicationGateway -ResourceGroupName MyResourceGroup
# # Specify the resource id to the user assigned managed identity - This can be found by going to the properties of the managed identity
# Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity"
# # Get the secret ID from Key Vault
# $secret = Get-AzKeyVaultSecret -VaultName "App-Catalog_keyvault" -Name "CertificateName"
# $secretId = $secret.Id.Replace($secret.Version, "") # Remove the secret version so AppGW will use the latest version in future syncs
# # Specify the secret ID from Key Vault
# Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $secret.Name
# # Commit the changes to the Application Gateway
# Set-AzApplicationGateway -ApplicationGateway $appgw


# https://docs.microsoft.com/en-us/azure/key-vault/general/security-features
# Key Vault authentication options. Applications can access Key Vault:
# Application-only: The application represents a service principal or managed identity. This identity is the most common scenario for applications that
# periodically need to access certificates, keys, or secrets from the key vault. For this scenario to work, the objectId of the application must be specified
# in the access policy and the applicationId must not be specified or must be null.

# Built-in Roles:
# General:
# Owner - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
# Contributor - Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.
# Reader - View all resources, but does not allow you to make any changes.
# User Access Administrator - Lets you manage user access to Azure resources.
# Security:
# Key Vault Administrator - Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Certificates Officer - Perform any action on the certificates of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Contributor - Lets you manage key vaults, but not access to them.
# Key Vault Crypto Officer - Perform any action on the keys of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Crypto Service Encryption User - Read metadata of keys and perform wrap/unwrap operations. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Crypto User - Perform cryptographic operations using keys. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Reader - Read metadata of key vaults and its certificates, keys, and secrets. Cannot read sensitive values such as secret contents or key material. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Secrets Officer - Perform any action on the secrets of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Key Vault Secrets User - Read secret contents. Only works for key vaults that use the 'Azure role-based access control' permission model.
# Analytics:
# Log Analytics Contributor - Log Analytics Contributor can read all monitoring data and edit monitoring settings. Editing monitoring settings includes adding the VM extension to VMs; reading storage account keys to be able to configure collection of logs from Azure Storage; adding solutions; and configuring Azure diagnostics on all Azure resources.
# Log Analytics Reader - Log Analytics Reader can view and search all monitoring data as well as and view monitoring settings, including viewing the configuration of Azure diagnostics on all Azure resources.
# Management + Governance:
# Managed Application Contributor Role - Allows for creating managed application resources.
# Managed Application Operator Role - Lets you read and perform actions on Managed Application resources
# Managed Applications Reader - Lets you read resources in a managed app and request JIT access.
# Resource Policy Contributor - Users with rights to create/modify resource policy, create support ticket and read resources/hierarchy.
# Monitor:
# Monitoring Contributor - Can read all monitoring data and update monitoring settings.
# Monitoring Metrics Publisher - Enables publishing metrics against Azure resources
# Monitoring Reader - Can read all monitoring data.

#id-kv-app-analysis-incliva   (get secrets)
#Microsoft.Azure.CertificateRegistration  (create import certs)
#  Microsoft.Azure.CertificateRegistration  00000000-0000-0000-0000-000000000000  App - Key Vault Certificates Officer
resource "azurerm_role_assignment" "appgateway_user_assigned_identity_keyvault_secrets" {
  for_each             = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  description          = "Key Vault Secrets User: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.App-Catalog_keyvault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.App-Catalog_agw[each.key].principal_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.App-Catalog_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}

resource "azurerm_role_assignment" "appgateway_user_assigned_identity_keyvault_certs" {
  for_each             = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  description          = "Key Vault Certificates Officer: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.App-Catalog_keyvault[each.key].id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_user_assigned_identity.App-Catalog_agw[each.key].principal_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.App-Catalog_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}

# Our App Service lacks of Certificate, hence the following block can be ignored:
# resource "azurerm_role_assignment" "App-Catalog" {
#   description          = "Key Vault Certificates Officer: RBAC role assignment to appr-app-analysis-myclient-dev (app service)"
#   scope                = azurerm_key_vault.App-Catalog_keyvault.id
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = azuread_service_principal.App-Catalog.id  # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
# }


resource "azurerm_role_assignment" "aks_computation_App-Catalog" {
  for_each    = toset(var.client_names)
  description = "DevTest Subscription - rg-aks-computation-devtest - aks-computation-devtest - List cluster admin credential action"
  #scope               = azurerm_resource_group.App-Catalog_rg.id
  scope                = data.azurerm_subscription.current.id # Subscription Scope
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.App-Catalog[each.key].object_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
}


####################################################################################################
# RBAC Contributor - Developers Group
####################################################################################################
resource "azurerm_role_assignment" "custom_admin" {
  for_each             = toset(var.client_names)
  role_definition_name = var.aad_developers_group_assigned_role # Built-in Role
  principal_id         = var.aad_developers_group
  #scope               = data.azurerm_subscription.current.id   # Subscription Scope
  scope = azurerm_resource_group.App-Catalog_rg[each.key].id
}
