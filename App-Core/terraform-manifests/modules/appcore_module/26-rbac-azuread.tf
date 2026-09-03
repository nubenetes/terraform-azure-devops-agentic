
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


#################################################################################################
# AAD Management Scope - Azure AD Roles - Attribute assignment reader | Asignments
# RoleAssignmentsClient.BaseClient.Post(): unexpected status 403 with OData
# error: Authorization_RequestDenied: Insufficient privileges to complete the
# operation.
#################################################################################################
resource "azuread_directory_role" "attribute_assignment_reader" {
  display_name = "Attribute assignment reader"
}
resource "azuread_directory_role_assignment" "attribute_assignment_reader_appcore_back_api" {
  # Requireb by appcore_back_api to modify "acceptedTermsAndConditions" Custom Security Attribute
  role_id             = azuread_directory_role.attribute_assignment_reader.template_id
  principal_object_id = azuread_service_principal.appcore_back_api.object_id
}
resource "azuread_directory_role_assignment" "attribute_assignment_reader_applink_cloud_api" {
  role_id             = azuread_directory_role.attribute_assignment_reader.template_id
  principal_object_id = azuread_service_principal.applink_cloud_api.object_id
}

###############################################################################################################################
# AAD Management Scope - Azure AD Roles - Attribute assignment administrator | Asignments
# Currently required by appcore-back-api to add "Accepted Terms and Conditions" Custom Security Attribute
# This flag is enabled by the user when login appcore platform by accepting the EULA terms and conditions (PDFs in this repo)
# These settings are temporary since a better solution will be carried out. 
###############################################################################################################################
resource "azuread_directory_role" "attribute_assignment_administrator" {
  display_name = "Attribute assignment administrator"
}
resource "azuread_directory_role_assignment" "attribute_assignment_administrator_appcore_back_api" {
  role_id             = azuread_directory_role.attribute_assignment_administrator.template_id
  principal_object_id = azuread_service_principal.appcore_back_api.object_id
}

####################################################################################################
# Assign a user and group to an internal application
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
# Manages an app role assignment for a group, user or service principal. Can be used to grant admin consent for application permissions.
#
# https://www.nathannellans.com/post/app-registration-enterprise-apps-part-2
# https://docs.microsoft.com/en-us/azure/architecture/multitenant-identity/app-roles
####################################################################################################
# resource "azuread_app_role_assignment" "appcore_back_api_applink_cloud_api" {
#   app_role_id         = random_uuid.applink_cloud_api_azurekeyvault_role_id.result
#   principal_object_id = azuread_service_principal.appcore_back_api.object_id
#   resource_object_id  = azuread_service_principal.applink_cloud_api.object_id
# }
