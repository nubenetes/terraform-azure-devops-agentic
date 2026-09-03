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
# $secret = Get-AzKeyVaultSecret -VaultName "appcore_keyvault" -Name "CertificateName"
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
# AKS:
# Azure Kubernetes Fleet Manager Contributor Role - Grants access to read and write Azure Kubernetes Fleet Manager clusters
# Azure Kubernetes Fleet Manager RBAC Admin - This role grants admin access - provides write permissions on most objects within a a namespace, with the exception of ResourceQuota object and the namespace object itself. Applying this role at cluster scope will give access across all namespaces.
# Azure Kubernetes Fleet Manager RBAC Cluster Admin - Lets you manage all resources in the fleet manager cluster.
# Azure Kubernetes Fleet Manager RBAC Reader - Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings. This role does not allow viewing Secrets, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation). Applying this role at cluster scope will give access across all namespaces.
# Azure Kubernetes Fleet Manager RBAC Writer - Allows read/write access to most objects in a namespace.This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace. Applying this role at cluster scope will give access across all namespaces.
# Azure Kubernetes Service Cluster Admin Role - List cluster admin credential action.
# Azure Kubernetes Service Cluster User Role - List cluster user credential action.
# Azure Kubernetes Service Contributor Role - Grants access to read and write Azure Kubernetes Service clusters
# Azure Kubernetes Service Policy Add-on Deployment - Deploy the Azure Policy add-on on Azure Kubernetes Service clusters
# Azure Kubernetes Service RBAC Admin - Lets you manage all resources under cluster/namespace, except update or delete resource quotas and namespaces.
# Azure Kubernetes Service RBAC Cluster Admin - Lets you manage all resources in the cluster.
# Azure Kubernetes Service RBAC Reader - Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings. This role does not allow viewing Secrets, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation). Applying this role at cluster scope will give access across all namespaces.
# Azure Kubernetes Service RBAC Writer - Allows read/write access to most objects in a namespace.This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets and running Pods as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace. Applying this role at cluster scope will give access across all namespaces.
# Kubernetes Cluster - Azure Arc Onboarding - Role definition to authorize any user/service to create connectedClusters resource
# Kubernetes Extension Contributor - Can create, update, get, list and delete Kubernetes Extensions, and get extension async operations
# Kubernetes Namespace User - Allows a user to read namespace resources and retrieve kubeconfig for the cluster
# Microsoft.Kubernetes connected cluster role - Microsoft.Kubernetes connected cluster role.

resource "azurerm_role_assignment" "appgateway_user_assigned_identity_keyvault_secrets" {
  description          = "Key Vault Secrets User: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.appcore_keyvault_agw.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appcore_agw.principal_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.appcore_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}
resource "azurerm_role_assignment" "appgateway_user_assigned_identity_keyvault_certs" {
  description          = "Key Vault Certificates Officer: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.appcore_keyvault_agw.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_user_assigned_identity.appcore_agw.principal_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.appcore_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}


####################################################################################################
# AKS Built-in roles: https://learn.microsoft.com/en-us/azure/aks/concepts-identity#built-in-roles
#
# Azure Kubernetes Service RBAC Reader:
#
#   Allows read-only access to see most objects in a namespace.
#   Doesn't allow viewing roles or role bindings.
#   Doesn't allow viewing Secrets. Reading the Secrets contents enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount
#   in the namespace (a form of privilege escalation).
#
# Azure Kubernetes Service RBAC Writer:
#
#   Allows read/write access to most objects in a namespace.
#   Doesn't allow viewing or modifying roles, or role bindings.
#   Allows accessing Secrets and running pods as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace.
#
# Azure Kubernetes Service RBAC Admin
#
#   Allows admin access, intended to be granted within a namespace.
#   Allows read/write access to most resources in a namespace (or cluster scope), including the ability to create roles and role bindings within the namespace.
#   Doesn't allow write access to resource quota or to the namespace itself.
#
# Azure Kubernetes Service RBAC Cluster Admin
#
#   Allows super-user access to perform any action on any resource.
#   Gives full control over every resource in the cluster and in all namespaces.
####################################################################################################
resource "azurerm_role_assignment" "aks_computation_applink_cloud_api" {
  description  = "RBAC on RG running AKS Computation"
  principal_id = azuread_service_principal.applink_cloud_api.object_id # (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
  #scope                = azurerm_resource_group.appcore_rg.id   # RG Scope
  #scope                = data.azurerm_subscription.current.id  # Subscription Scope
  #####################################################################################################
  # Kubernetes Service Cluster Admin Role
  # Temporary workaround since apparently "kubernetes jobs cannot be triggered without this perm..."
  #####################################################################################################
  scope                = local.aks_rbac_cluster_scope
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role" # Temporary workaround since apparently "kubernetes jobs cannot be triggered without this perm..."
  #####################################################################################################
  # Kubernetes Service RBAC Writer (namespace scope)
  # Preferred permission:
  #####################################################################################################
  #scope                =  local.aks_rbac_namespace_scope
  #role_definition_name = "Azure Kubernetes Service RBAC Writer"  # A more reasonable RBAC permission within namespace scope
}


####################################################################################################
# Cloud Admins Group - RBAC
####################################################################################################
resource "azurerm_role_assignment" "aad_cloud_administrators_group_contributor" {
  role_definition_name = "Contributor" # Built-in Role
  principal_id         = var.aad_administrators_group
  scope                = azurerm_resource_group.appcore_rg.id # RG Scope
  #scope                = data.azurerm_subscription.current.id  # Subscription Scope
}
resource "azurerm_role_assignment" "aad_cloud_administrators_keyvault_appgateway" {
  role_definition_name = "Key Vault Administrator" # Built-in Role
  principal_id         = var.aad_administrators_group
  scope                = azurerm_key_vault.appcore_keyvault_agw.id # Key Vault Scope
}
resource "azurerm_role_assignment" "appgateway_aad_cloud_administrators_keyvault_secrets" {
  description          = "Key Vault Secrets User: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.appcore_keyvault_agw.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.aad_administrators_group
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.appcore_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}
resource "azurerm_role_assignment" "appgateway_aad_cloud_administrators_keyvault_certs" {
  description          = "Key Vault Certificates Officer: RBAC role assignment to appgateway user assigned identity"
  scope                = azurerm_key_vault.appcore_keyvault_agw.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = var.aad_administrators_group
  #delegated_managed_identity_resource_id = azurerm_user_assigned_identity.appcore_agw.id # (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
}
####################################################################################################
# Developers Group - RBAC
####################################################################################################
resource "azurerm_role_assignment" "aad_developers_group_contributor" {
  role_definition_name = var.aad_developers_group_assigned_role # Built-in Role
  principal_id         = var.aad_developers_group
  scope                = azurerm_resource_group.appcore_rg.id # RG Scope
  #scope                = data.azurerm_subscription.current.id  # Subscription Scope
}
resource "azurerm_role_assignment" "aad_developers_group_keyvault_appgateway" {
  role_definition_name = var.vault_rbac_aad_developers_group_permissions # Built-in Role
  principal_id         = var.aad_developers_group
  scope                = azurerm_key_vault.appcore_keyvault_agw.id # Key Vault Scope
}


####################################################################################################
# RBAC Storage Blob Data Reader - Developers Group
####################################################################################################
resource "azurerm_role_assignment" "aad_developers_group_storage_blob_data_reader" {
  role_definition_name = var.aad_developers_group_storage_blob_assigned_role # Built-in Role
  principal_id         = var.aad_developers_group
  scope                = azurerm_storage_container.appcore.resource_manager_id
}

####################################################################################################
# RBAC Storage Blob Data Reader - App-Core Front
####################################################################################################
resource "azurerm_role_assignment" "appcore_front_storage_blob_data_reader" {
  role_definition_name = "Storage Blob Data Reader" # Built-in role: Allows for read access to Azure Storage blob containers and data.
  principal_id         = azuread_service_principal.appcore_front_spa.id
  scope                = azurerm_storage_container.appcore.resource_manager_id
}

####################################################################################################
# RBAC Storage Blob Data Reader - App-Link Cloud
####################################################################################################
resource "azurerm_role_assignment" "applink_cloud_storage_blob_data_reader" {
  role_definition_name = "Storage Blob Data Reader" # Built-in role: Allows for read access to Azure Storage blob containers and data.
  principal_id         = azuread_service_principal.applink_cloud_api.id
  scope                = azurerm_storage_container.appcore.resource_manager_id
}


####################################################################################################
# RBAC Log Analytics Workspace from appcore Back API
# https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access
####################################################################################################
resource "azurerm_role_assignment" "appcore_back_api" {
  #for_each             = toset(var.client_names)
  role_definition_name = "Log Analytics Contributor"
  # Built-in role: Log Analytics Contributor can read all monitoring data and edit monitoring settings. Editing monitoring settings includes adding the VM extension to VMs; reading storage account keys to be able to configure collection of logs from Azure Storage; adding solutions; and configuring Azure diagnostics on all Azure resources.
  principal_id = azuread_service_principal.appcore_back_api.id
  #scope                = azurerm_log_analytics_workspace.appcore_myclient[each.key].id
  scope = azurerm_log_analytics_workspace.appcore_back.id
}

resource "azurerm_role_assignment" "applink_cloud" {
  #for_each             = toset(var.client_names)
  role_definition_name = "Log Analytics Contributor"
  # Built-in role: Log Analytics Contributor can read all monitoring data and edit monitoring settings. Editing monitoring settings includes adding the VM extension to VMs; reading storage account keys to be able to configure collection of logs from Azure Storage; adding solutions; and configuring Azure diagnostics on all Azure resources.
  principal_id = azuread_service_principal.applink_cloud_api.id
  #scope                = azurerm_log_analytics_workspace.appcore_myclient[each.key].id
  scope = azurerm_log_analytics_workspace.applink_cloud.id
}


####################################################################################################
# Custom Role & Management Group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
####################################################################################################
#
# resource "azurerm_role_definition" "custom_admin" {
#   name               = "Custom Role Admin"
#   scope              = data.azurerm_subscription.current.id # azuread_application.appcore_back_api.application_id #app_role_ids[role_definition_id]
#   description        = "Custom Role Admin PoC"
#   permissions {
#     actions          = ["*"]
#     not_actions      = []
#     data_actions     = ["*"]
#     not_data_actions = []
#   }
#   # assignable_scopes = [
#   #   azurerm_resource_group.appcore_rg.id, # /subscriptions/00000000-0000-0000-0000-000000000000
#   # ]
# }
# resource "azurerm_role_definition" "custom_user" {
#   name               = "Custom Role User"
#   scope              = data.azurerm_subscription.current.id  # azuread_application.appcore_back_api.application_id #app_role_ids[role_definition_id]
#   description        = "Custom Role User PoC"
#   permissions {
#     actions           = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
#     not_actions       = []
#     #data_actions      = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
#     not_data_actions  = []
#   }
#   # assignable_scopes = [
#   #   azurerm_resource_group.appcore_rg.id, # /subscriptions/00000000-0000-0000-0000-000000000000
#   # ]
# }
# resource "azurerm_role_assignment" "custom_admin" {
#   for_each             = toset(var.client_names)
#   role_definition_id   = azurerm_role_definition.custom_admin.role_definition_resource_id
#   principal_id         = azuread_group.appcore_admin_role[each.key].object_id
#   scope                = data.azurerm_subscription.current.id
# }
# resource "azurerm_role_assignment" "custom_user" {
#   for_each             = toset(var.client_names)
#   role_definition_id   = azurerm_role_definition.custom_user.role_definition_resource_id
#   principal_id         = azuread_group.appcore_user_role[each.key].object_id
#   scope                = data.azurerm_subscription.current.id
# }
