#################################################################################################################################################
# Application registrations in Azure Active Directory for use in App-Core application that utilises OAuth2 on the Microsoft Identity Platform
#
# App-Core Frontend is App-Core Web Application
# App-Core Backend is App-Core API Service
#################################################################################################################################################

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
# https://www.mytechramblings.com/posts/automate-azure-ad-app-registration-using-terraform/
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application

##############################################################################################################################
# Existing OAuth 2.0 Token Grant Flows and Scopes:
# - "user_impersonation": OAuth 2.0 Scope with OBO flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
# - "access_as_user": OAuth 2.0 Scope with implicit flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
##############################################################################################################################

##############################################################################################################################
# Token Grant Flow USED by App-Core (choose one):
# - "user_impersonation": OAuth 2.0 OBO Flow: https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
# - "access_as_user": OAuth 2.0 implicit flow: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
# - etc
##############################################################################################################################

############################################################################################################################
# Token Grant Flows NOT USED By Enterprise:
# - Implicit Grant Flow: https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
#   Implicit (Grant) Flow example: https://github.com/hashicorp/terraform-provider-azuread/tree/main/examples/application
#
# - OpenID Connect (OIDC): https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc
#############################################################################################################################

##################################################################################################################
# Request API permissions - Microsoft Graph
# Two types of permissions:
# - Delegated permissions (Scope): Your application needs to access the API as the signed-in user.
# - Application permissions (Role): Your application runs as a background service or daemon without a signed-in user.
##################################################################################################################

####################################################################################################################################################################################
# Enable Azure Active Directory in your App Service app
# https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-create-an-app-registration-in-azure-ad-for-your-app-service-app
####################################################################################################################################################################################

#####################################################################################################################################################################################################
# Roles and Permission Scopes
# In Azure Active Directory, application roles (app_role) and permission scopes (oauth2_permission_scope) exported by an application share the same namespace and cannot contain duplicate values.
# Terraform will attempt to detect this during a plan or apply operation.
#####################################################################################################################################################################################################

####################################################################################################################################################################################
# Code Samples:
# - mytechramblings.com: Trying to automate Azure Active Directory App Registration process using Terraform
#   https://www.mytechramblings.com/posts/automate-azure-ad-app-registration-using-terraform/
# - github.com/Azure-Samples: Tutorial: Enable your JavaScript single-page application (SPA) to sign-in users and call APIs with the Microsoft identity platform
#   https://github.com/Azure-Samples/ms-identity-javascript-tutorial
# - github.com/Azure-Samples: Handling Conditional Access challenges in an Azure AD protected Node.js web API calling another protected Node.js web API on behalf of a user
#   https://github.com/Azure-Samples/ms-identity-javascript-tutorial/tree/main/4-AdvancedGrants/2-call-api-api-ca
# - github.com/Azure-Samples: Add authorization using App roles to a React single-page app that signs-in users and calls a protected Node.js Web Api
#   https://github.com/Azure-Samples/ms-identity-javascript-react-tutorial/tree/main/5-AccessControl/1-call-api-roles
#   If you like to use MSAL instead of App Service auth (you'll have to switch it off on App Service portal.
# - github.com/Azure-Samples: A Node.js Web API secured by Azure AD and calling Microsoft Graph on behalf of a signed-in user
#   https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md
#####################################################################################################################################################################################

########################################################################################################################################
# Why is Azure Storage API permission not listed in azure portal?
# https://stackoverflow.com/questions/55415534/why-is-azure-storage-api-permission-not-listed-in-azure-portal
#
# Azure Storage Authentication - Use OAuth access tokens for authentication:
# https://learn.microsoft.com/en-gb/rest/api/storageservices/authorize-with-azure-active-directory#use-oauth-access-tokens-for-authentication
#
# Azure Key Vault Authentication:
# https://learn.microsoft.com/en-us/azure/key-vault/general/authentication
# https://learn.microsoft.com/en-gb/rest/api/keyvault/
########################################################################################################################################

##############################################################################################################################################################################################################
# Azure AD – Determine App Roles and Scope Permissions
# https://acloudguy.com/2000/01/01/azure-ad-determine-app-roles-and-scope-permissions/
#
# Adding a new application in Azure AD using a portal can be done with a few clicks in the ‘App Registration’ blade.
# Adding API permissions in this application is also not a big deal but when you are using PowerShell cmdlets like I did in this earlier blogpost, you will need to know App IDs, App Role ID and Permission Scope IDs.
#
# These also plays a critical role while using Terraform to deploy Azure AD applications (azuread_application), where the required_resource_access argument in terraform azuread_application resource to set the permissions for the app being created.
# If you are creating the app via the portal, you may not need all this information but when you are going down the automation route, these values play a vital role in setting up the Azure AD applications properly.
#
# Some of common application IDs for some Microsoft resources:
# - Azure Key Vault: 00000000-0000-0000-0000-000000000000
# - Microsoft Graph: 00000000-0000-0000-0000-000000000000
# - etc
#
# $appid = "00000000-0000-0000-0000-000000000000"  # Azure Key Vault
# Get Service Principals
# $spList = az ad sp list --all
# $spListObj = $spList | ConvertFrom-Json
# Get Permissions
# $SP = $spListObj | Where-Object {$_.appID -eq $appid} | Select-Object
#
# accountEnabled                         : True
# addIns                                 : {}
# alternativeNames                       : {}
# appDescription                         :
# appDisplayName                         : Azure Key Vault
# appId                                  : 00000000-0000-0000-0000-000000000000
# appOwnerOrganizationId                 : 00000000-0000-0000-0000-000000000000
# appRoleAssignmentRequired              : False
# appRoles                               : {}
# applicationTemplateId                  :
# createclient-exampleteTime                        : 01/01/2000 14:05:15
# deleteclient-exampleteTime                        :
# description                            :
# disabledByMicrosoftStatus              :
# displayName                            : Azure Key Vault
# homepage                               :
# id                                     : 00000000-0000-0000-0000-000000000000
# info                                   : @{logoUrl=; marketingUrl=; privacyStatementUrl=; supportUrl=; termsOfServiceUrl=}
# keyCredentials                         : {}
# loginUrl                               :
# logoutUrl                              :
# notes                                  :
# notificationEmailAddresses             : {}
# oauth2PermissionScopes                 : {@{adminConsentDescription=Allow the application full access to the Azure Key Vault service on behalf of the signed-in user; adminConsentDisplayName=Have full access to the Azure Key Vault service; id=00000000-0000-0000-0000-000000000000; isEnabled=True; type=User;
#                                          userConsentDescription=Allow the application full access to the Azure Key Vault service on your behalf; userConsentDisplayName=Have full access to the Azure Key Vault service; value=user_impersonation}}
# passwordCredentials                    : {}
# preferredSingleSignOnMode              :
# preferredTokenSigningKeyThumbprint     :
# replyUrls                              : {}
# resourceSpecificApplicationPermissions : {}
# samlSingleSignOnSettings               : @{relayState=}
# servicePrincipalNames                  : {00000000-0000-0000-0000-000000000000, https://vault.azure.net}
# servicePrincipalType                   : Application
# signInAudience                         : AzureADMultipleOrgs
# tags                                   : {disableLegacyUserImpersonationResource, disableLegacyUserImpersonationClient}
# tokenEncryptionKeyId                   :
# verifiedPublisher                      : @{addeclient-exampleteTime=; displayName=; verifiedPublisherId=}
#
#
# With Role permissions:
# DeviceManagementRBAC.Read.All	00000000-0000-0000-0000-000000000000	Read Microsoft Intune RBAC settings
# DeviceManagementRBAC.ReadWrite.All	00000000-0000-0000-0000-000000000000	Read and write Microsoft Intune RBAC settings
# RoleManagement.Read.All	00000000-0000-0000-0000-000000000000	Read role management data for all RBAC providers
# RoleManagement.Read.CloudPC	00000000-0000-0000-0000-000000000000	Read Cloud PC RBAC settings
# RoleManagement.Read.Directory	00000000-0000-0000-0000-000000000000	Read all directory RBAC settings
# RoleManagement.ReadWrite.CloudPC	00000000-0000-0000-0000-000000000000	Read and write all Cloud PC RBAC settings
# RoleManagement.ReadWrite.Directory	00000000-0000-0000-0000-000000000000	Read and write all directory RBAC settings
# Policy.Read.ConditionalAccess	00000000-0000-0000-0000-000000000000	Read your organization’s conditional access policies
# Policy.ReadWrite.ConditionalAccess	00000000-0000-0000-0000-000000000000	Read and write your organization’s conditional access policies
#
# With Scope permissions:
# DeviceManagementRBAC.Read.All	00000000-0000-0000-0000-000000000000	Admin	Read Microsoft Intune RBAC settings
# DeviceManagementRBAC.ReadWrite.All	00000000-0000-0000-0000-000000000000	Admin	Read and write Microsoft Intune RBAC settings
# RoleManagement.Read.All	00000000-0000-0000-0000-000000000000	Admin	Read role management data for all RBAC providers
# RoleManagement.Read.CloudPC	00000000-0000-0000-0000-000000000000	Admin	Read Cloud PC RBAC settings
# RoleManagement.Read.Directory	00000000-0000-0000-0000-000000000000	Admin	Read directory RBAC settings
# RoleManagement.ReadWrite.CloudPC	00000000-0000-0000-0000-000000000000	Admin	Read and write Cloud PC RBAC settings
# RoleManagement.ReadWrite.Directory	00000000-0000-0000-0000-000000000000	Admin	Read and write directory RBAC settings
# Policy.Read.ConditionalAccess	00000000-0000-0000-0000-000000000000	User	Read your organization’s conditional access policies
# Policy.ReadWrite.ConditionalAccess	00000000-0000-0000-0000-000000000000	Admin	Read and write your organization’s conditional access policies
##############################################################################################################################################################################################################

##############################################################################################################################################################################################################
# Gaining consent for the middle-tier application
# The goal of the OBO flow is to ensure proper consent is given so that the client app can call the middle-tier app and the middle-tier app has permission to call the back-end resource.
# Depending on the architecture or usage of your application, you may want to consider the following to ensure that OBO flow is successful.
# https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow#gaining-consent-for-the-middle-tier-application
##############################################################################################################################################################################################################


##############################################################################################################################################################################################################
# Known Error on appcore_back_api:
#
# applink_CLOUD_API is setup with "OAuth 2.0 token endpoint v1" (JSON Web Token (JWT) Grant authentication V1)
# Errors obtained on appcar_back_api when "requested_access_token_version = 2" is enabled here:
# "GET /core/pipeline-definition"
# "Service Unavailable"
# "Error trying to retrieve all the series standards from applink."
# Http failure response for https://client-anon-app-envdev.deng.enterprise.com/core/pipeline-definition: 503 OK
# "HttpErrorResponse"
#
# Required settings:
#	"oauth2AllowIdTokenImplicitFlow": true,
#	"oauth2AllowImplicitFlow": true,
##############################################################################################################################################################################################################

resource "azuread_application" "appcore_back_api" {
  display_name     = local.appr_name_appcore_back_api
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = ["api://${local.appr_name_appcore_back_api}"] # A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant.

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }
  #####################################################
  # API
  #####################################################
  api {
    # https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad
    # https://blog.devgenius.io/calling-terraform-modules-for-azure-active-directory-azuread-3f89e4404d22
    #mapped_claims_enabled          = true #(Optional) Allows an application to use claims mapping without specifying a custom signing key. Defaults to false.
    requested_access_token_version = 2
    # Manifest blade - Sets accessTokenAcceptedVersion property to 2 - https://github.com/hashicorp/terraform-provider-azuread/issues/188
    # https://learn.microsoft.com/en-gb/azure/active-directory/develop/reference-app-manifest#accesstokenacceptedversion-attribute
    known_client_applications = [azuread_application.appcore_front_spa.application_id]
    # (Optional) A set of application IDs (client IDs), used for bundling consent if you have a solution that contains two parts: a client app and a custom web API app.
    # Configure knownClientApplications for service app https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md#configure-knownclientapplications-for-service-app
    # For a middle tier Web API to be able to call a downstream Web API, the middle tier app needs to be granted the required permissions as well. However, since the middle tier cannot interact with the signed-in user, it needs
    # to be explicitly bound to the client app in its Azure AD registration. This binding merges the permissions required by both the client and the middle tier Web Api and presents it to the end user in a single consent dialog.
    # The user then consent to this combined set of permissions.
    # These settings will be added to the manifest of the registered app
    ##########################################################################################
    # PERMISSION SCOPES (oauth2_permission_scope) - Delegated Permissions (Scope)
    # Access to the following Azure PaaS services with "user_impersonation" (OBO Flow):
    #   - Azure Key Vault API
    #   - Azure Storage
    ###########################################################################################
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access App-Core Backend on behalf of the signed-in user"
      admin_consent_display_name = "Access App-Core Backend"
      enabled                    = true
      # Tip: Generating a UUID for the id field. To generate a value for the id field in cases where the actual UUID is not important, you can use the random_uuid resource. See the application example in the provider repository.
      # https://github.com/hashicorp/terraform-provider-azuread/tree/main/examples/application
      id                        = random_uuid.appcore_back_api_user_scope_id.result
      type                      = "User"
      user_consent_description  = "Allow the application to access App-Core Backend on your behalf"
      user_consent_display_name = "Access App-Core Backend as a user"
      value                     = "user_impersonation"
      # "user_impersonation" = OAuth 2.0 Scope with OBO flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
      # "user_impersonation" matches the settings in "Access to Azure Key Vault API":
      #          azuread_application.appcore_back_api.required_resource_access - AzureKeyVault - resource_access.id = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
      #          azuread_application.appcore_back_api.required_resource_access - AzureStorage  - resource_access.id = azuread_service_principal.storage.oauth2_permission_scope_ids["user_impersonation"]
      # Unlike the Azure Portal, applications created with the Terraform AzureAD provider do not get assigned a default user_impersonation scope. You will need to include a block for the user_impersonation scope if you need it for your application.
    }
    # oauth2_permission_scope {
    #   admin_consent_description  = "Administer App-Core Backend"
    #   admin_consent_display_name = "Administer App-Core Backend"
    #   enabled                    = true
    #   id                         = random_uuid.appcore_back_api_admin_scope_id.result
    #   type                       = "Admin"
    #   value                      = "administer"  # OAuth 2.0 Scope
    # }
  }
  ##############################################################################################################################################
  # ROLES (app_role)
  # app_role - Two Roles:
  #   1) Admin:
  #      Used by Vault Access Policy - Compound Identity: azurerm_key_vault_access_policy.compound_identity_appcore_back_api_app_role_admin
  #      Test user: cloud-admin@example.com
  #   2) Viewer:
  #      Used by Vault Access Policy - Compound Identity: azurerm_key_vault_access_policy.compound_identity_appcore_back_api_app_role_viewer
  #      Test user: cloud-admin@example.com
  ##############################################################################################################################################
  # 1) azurerm_key_vault_access_policy.compound_identity_appcore_back_api_app_role_admin :
  app_role {
    allowed_member_types = ["User"]
    description          = "Admins can manage roles and perform all task actions"
    display_name         = "App-Core Admin" #"Admin"
    enabled              = true
    id                   = random_uuid.appcore_back_api_admin_role_id.result
    value                = "Admin"
  }
  # 2) azurerm_key_vault_access_policy.compound_identity_appcore_back_api_app_role_viewer :
  app_role {
    allowed_member_types = ["User"]
    description          = "ReadOnly roles have limited query access"
    display_name         = "App-Core User" #"ReadOnly"
    enabled              = true
    id                   = random_uuid.appcore_back_api_user_role_id.result
    value                = "Viewer"
  }

  ##################################################################################################################
  # Access to applink_cloud_api
  ##################################################################################################################
  # required_resource_access {
  #   resource_app_id = azuread_application.applink_cloud_api.application_id
  #   dynamic resource_access {
  #     for_each = azuread_application.applink_cloud_api.api.0.oauth2_permission_scope
  #     iterator = scope
  #     content {
  #       id   = scope.value.id
  #       type = "Scope"  # Delegated permission
  #     }
  #   }
  # }
  ##################################################################################################################
  # Access to Azure Key Vault API with "user_impersonation" (OBO Flow)
  #
  # - How To Access Azure Key Vault Secrets Through Rest API Using Postman (OAuth 2.0 client credentials grant):
  #   https://www.c-sharpcorner.com/article/how-to-access-azure-key-vault-secrets-through-rest-api-using-postman/
  #   https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow
  # - OUR USE CASE: How to Access Azure Key Vault Secrets Through Rest API wit OAuth 2.0 on-behalf-of flow:
  #   https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
  ##################################################################################################################
  # required_resource_access {
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureKeyVault
  #       # Azure Key Vault - Check thist nofficial source of application IDs https://github.com/manicminer/hamilton/blob/main/environments/published.go
  #   resource_access {
  #     id   = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
  #         # user_impersonation - Allow the application full access to the Azure Key Vault service on behalf of the signed-in user (Admin consent NOT required)
  #         # matches the settings in oauth2_permission_scope - value = "user_impersonation"
  #     type = "Scope" # Delegated
  #     ##############################################################################################################################################################
  #     # The "Admin consent required" column shows the default value for an organization. However, user consent can be customized per permission, user, or app.
  #     # This column may not reflect the value in your organization, or in organizations where this app will be used.
  #     # https://go.microsoft.com/fwlink/?linkid=2152292
  #     ##############################################################################################################################################################
  #     # Azure Key Vault REST API: https://learn.microsoft.com/en-us/rest/api/keyvault/
  #   }
  # }

  required_resource_access {
    resource_app_id = "00000000-0000-0000-0000-000000000000" # Azure Key Vault
    resource_access {
      id   = "00000000-0000-0000-0000-000000000000" # user_impersonation
      type = "Scope"                                # Delegated
    }
  }

  ##################################################################################################################
  # Access to Azure Storage API with "user_impersonation" (OBO Flow)
  ##################################################################################################################
  # required_resource_access {
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureStorage
  #       # Azure Key Vault - Check thist nofficial source of application IDs https://github.com/manicminer/hamilton/blob/main/environments/published.go
  #   resource_access {
  #     id   = azuread_service_principal.storage.oauth2_permission_scope_ids["user_impersonation"]
  #         # user_impersonation - Allow the application full access to the Azure Storage service on behalf of the signed-in user (Admin consent NOT required)
  #         # matches the settings in oauth2_permission_scope - value = "user_impersonation"
  #     type = "Scope" # Delegated
  #     ##############################################################################################################################################################
  #     # The "Admin consent required" column shows the default value for an organization. However, user consent can be customized per permission, user, or app.
  #     # This column may not reflect the value in your organization, or in organizations where this app will be used.
  #     # https://go.microsoft.com/fwlink/?linkid=2152292
  #     ##############################################################################################################################################################
  #     # Azure Storage REST API Reference: https://learn.microsoft.com/en-us/rest/api/storageservices/
  #   }
  # }

  required_resource_access {
    resource_app_id = "00000000-0000-0000-0000-000000000000" # Azure Storage
    resource_access {
      id   = "00000000-0000-0000-0000-000000000000" # user_impersonation
      type = "Scope"
    }
  }

  ##########################################################################################################################################
  # Acess to Microsoft Graph API
  # Request API permissions - Microsoft Graph
  # Two types of permissions:
  # - Delegated permissions (Scope): Your application needs to access the API as the signed-in user.
  # - Application permissions (Role): Your application runs as a background service or daemon without a signed-in user.
  # https://stackoverflow.com/questions/65241844/whats-the-difference-between-user-read-vs-openid-profile-email-permissions-in-a
  # So there you have it. Add User.Read if you want to query anything from the Graph APIs,
  # else just use openid (and optionally profile email) if you are happy just signing users in and using the id_token for your needs.
  #
  # https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
  ##########################################################################################################################################
  required_resource_access {
    # Microsoft Graph
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    # resource_access { # Remove the default “User.Read Delegated” permissions
    #   # User.Read - Sign in and read user profile
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]   # Microsoft Graph Procotol
    #   type = "Scope" # Delegated
    # }
    resource_access {
      # openid - Sign users in
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # OIDC Protocol
      type = "Scope"                                                                 # Delegated
    }
    resource_access {
      # Offline_access - Maintain access to data you have given it access to
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"] # OIDC Protocol
      type = "Scope"                                                                         # Delegated
    }
  }
  depends_on = [
    azuread_application.appcore_front_spa,
  ]
}


resource "azuread_application" "applink_cloud_api" {
  display_name     = local.appr_name_applink_cloud_api
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = ["api://${local.appr_name_applink_cloud_api}"] # A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant.

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }
  #####################################################
  # API
  #####################################################
  api {
    #mapped_claims_enabled          = true #(Optional) Allows an application to use claims mapping without specifying a custom signing key. Defaults to false.
    #requested_access_token_version = 2
    # https://learn.microsoft.com/en-gb/azure/active-directory/develop/reference-app-manifest#accesstokenacceptedversion-attribute
    known_client_applications = [azuread_application.appcore_front_spa.application_id, azuread_application.appcore_back_api.application_id]
    #known_client_applications = [azuread_application.appcore_front_spa.application_id]
    #known_client_applications = [azuread_application.appcore_back_api.application_id]
    # Configure knownClientApplications for service app https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md#configure-knownclientapplications-for-service-app
    # For a middle tier Web API to be able to call a downstream Web API, the middle tier app needs to be granted the required permissions as well. However, since the middle tier cannot interact with the signed-in user, it needs
    # to be explicitly bound to the client app in its Azure AD registration. This binding merges the permissions required by both the client and the middle tier Web Api and presents it to the end user in a single consent dialog.
    # The user then consent to this combined set of permissions.
    # These settings will be added to the manifest of the registered app
    ##########################################################################################
    # PERMISSION SCOPES (oauth2_permission_scope) - Delegated Permissions (Scope)
    # Access to the following Azure PaaS services with "user_impersonation" (OBO Flow):
    #   - Azure Key Vault API
    #   - applink_cloud_api: NO access to Azure Storage via OBO Flow
    ###########################################################################################
    oauth2_permission_scope {
      admin_consent_description  = "Allow Basic Operations"
      admin_consent_display_name = "General Access"
      enabled                    = true
      id                         = random_uuid.applink_cloud_api_user_scope_id.result
      type                       = "User"
      value                      = "General" # The value that is used for the scp claim in OAuth 2.0 access tokens.
    }
    # oauth2_permission_scope {
    #   admin_consent_description  = "Allow the application to access App-Link Cloud on behalf of the signed-in user"
    #   admin_consent_display_name = "Access App-Link Cloud"
    #   enabled                    = true
    #   # Tip: Generating a UUID for the id field. To generate a value for the id field in cases where the actual UUID is not important, you can use the random_uuid resource. See the application example in the provider repository.
    #   # https://github.com/hashicorp/terraform-provider-azuread/tree/main/examples/application
    #   id                         = random_uuid.applink_cloud_api_user_scope_id.result
    #   type                       = "User"
    #   user_consent_description   = "Allow the application to access App-Link Cloud on your behalf"
    #   user_consent_display_name  = "Access App-Link Cloud as a user"
    #   value                      = "user_impersonation"
    #       # "user_impersonation" = OAuth 2.0 Scope with OBO flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
    #       # "user_impersonation" matches the settings in "Access to Azure Key Vault API":
    #       #          azuread_application.appcore_back_api.required_resource_access - AzureKeyVault - resource_access.id = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
    #       #          azuread_application.appcore_back_api.required_resource_access - AzureStorage  - resource_access.id = azuread_service_principal.storage.oauth2_permission_scope_ids["user_impersonation"]
    #       # Unlike the Azure Portal, applications created with the Terraform AzureAD provider do not get assigned a default user_impersonation scope. You will need to include a block for the user_impersonation scope if you need it for your application.
    # }
    # oauth2_permission_scope {
    #   admin_consent_description  = "Administer App-Link Cloud"
    #   admin_consent_display_name = "Administer App-Link Cloud"
    #   enabled                    = true
    #   id                         = random_uuid.applink_cloud_api_admin_scope_id.result
    #   type                       = "Admin"
    #   value                      = "administer"  # OAuth 2.0 Scope
    # }
  }
  ######################################################################################################################
  # Access to Azure Key Vault API with "user_impersonation" (OBO Flow)
  #
  # - How To Access Azure Key Vault Secrets Through Rest API Using Postman (OAuth 2.0 client credentials grant):
  #   https://www.c-sharpcorner.com/article/how-to-access-azure-key-vault-secrets-through-rest-api-using-postman/
  #   https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow
  # - OUR USE CASE: How to Access Azure Key Vault Secrets Through Rest API wit OAuth 2.0 on-behalf-of flow:
  #   https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
  ######################################################################################################################
  # required_resource_access {
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureKeyVault
  #       # Azure Key Vault - Check thist nofficial source of application IDs https://github.com/manicminer/hamilton/blob/main/environments/published.go
  #   resource_access {
  #     id   = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
  #         # user_impersonation - Allow the application full access to the Azure Key Vault service on behalf of the signed-in user (Admin consent NOT required)
  #         # matches the settings in oauth2_permission_scope - value = "user_impersonation"
  #     type = "Scope" # Delegated
  #     ##############################################################################################################################################################
  #     # The "Admin consent required" column shows the default value for an organization. However, user consent can be customized per permission, user, or app.
  #     # This column may not reflect the value in your organization, or in organizations where this app will be used.
  #     # https://go.microsoft.com/fwlink/?linkid=2152292
  #     ##############################################################################################################################################################
  #     # Azure Key Vault REST API: https://learn.microsoft.com/en-us/rest/api/keyvault/
  #   }
  # }
  required_resource_access {
    resource_app_id = "00000000-0000-0000-0000-000000000000" # Azure Key Vault
    resource_access {
      id   = "00000000-0000-0000-0000-000000000000" # user_impersonation
      type = "Scope"                                # Delegated
    }
  }

  ####################################################################################################################################
  # Access to Microsoft Graph API
  # https://stackoverflow.com/questions/65241844/whats-the-difference-between-user-read-vs-openid-profile-email-permissions-in-a
  # So there you have it. Add User.Read if you want to query anything from the Graph APIs,
  # else just use openid (and optionally profile email) if you are happy just signing users in and using the id_token for your needs.
  #
  # https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
  ####################################################################################################################################
  required_resource_access {
    # Microsoft Graph
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    # resource_access {
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.AccessAsUser.All"]
    #   type = "Scope"  # Delegated
    # }
    # resource_access {
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"]
    #   type = "Scope"  # Delegated
    # }
    # resource_access { # Remove the default “User.Read Delegated” permissions
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]   # User.Read - Sign in and read user profile    # Microsoft Graph Procotol
    #   type = "Scope"  # Delegated
    # }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # openid - Sign users in # OIDC Protocol
      type = "Scope"                                                                 # Delegated
    }
    resource_access {
      # Offline_access - Maintain access to data you have given it access to
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"] # OIDC Protocol
      type = "Scope"                                                                         # Delegated
    }
  }
}

resource "azuread_application" "app-analysis_viewer_back_api_myclient" {
  for_each = toset(var.client_names)
  #display_name      = local.appr_name_analysis_viewer_back_api
  display_name     = "appr-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${each.value}-${local.instance_environment}"
  owners           = [data.azurerm_client_config.current.object_id]
  identifier_uris  = ["api://appr-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${each.value}-${local.instance_environment}"] # A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant.
  sign_in_audience = "AzureADMyOrg"

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }
  #####################################################
  # API
  #####################################################
  api {
    requested_access_token_version = 2 # Manifest blade - Sets accessTokenAcceptedVersion property to 2 - https://github.com/hashicorp/terraform-provider-azuread/issues/188
    # known_client_applications = [
    #   # Configure knownClientApplications for service app https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md#configure-knownclientapplications-for-service-app
    #   azuread_application.app-analysis_viewer_front_spa.application_id,
    # ]
    ##################################################################################
    # PERMISSION SCOPES (oauth2_permission_scope) - Delegated Permissions (Scope)
    # Access to the following Azure PaaS services with "user_impersonation" (OBO Flow):
    #   - Azure Key Vault API
    #   - Azure Storage
    ###################################################################################
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access appr-viewer-backend on behalf of the signed-in user."
      admin_consent_display_name = "Access appr-viewer-backend"
      enabled                    = true
      id                         = random_uuid.app-analysis_viewer_back_api_myclient_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access appr-viewer-backend on your behalf."
      user_consent_display_name  = "Access appr-viewer-backend"
      #value                      = "user_impersonation"
      # "user_impersonation" = OAuth 2.0 Scope with OBO flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
      # "user_impersonation" matches the settings in azuread_application.app-analysis_viewer_back_api_myclient.required_resource_access.resource_access.id = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
      # Unlike the Azure Portal, applications created with the Terraform AzureAD provider do not get assigned a default user_impersonation scope. You will need to include a block for the user_impersonation scope if you need it for your application.
      value = "access_as_user" # OAuth 2.0 Scope with implicit flow https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
    }
  }
  ##################################################################################################################
  # Access to Azure Key Vault API
  #
  # - How To Access Azure Key Vault Secrets Through Rest API Using Postman (OAuth 2.0 client credentials grant):
  #   https://www.c-sharpcorner.com/article/how-to-access-azure-key-vault-secrets-through-rest-api-using-postman/
  #   https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow
  # - OUR USE CASE: How to Access Azure Key Vault Secrets Through Rest API wit OAuth 2.0 on-behalf-of flow:
  #   https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow
  ##################################################################################################################
  # required_resource_access {
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureKeyVault
  #       # Azure Key Vault - Check thist nofficial source of application IDs https://github.com/manicminer/hamilton/blob/main/environments/published.go
  #   resource_access {
  #     id   = azuread_service_principal.keyvault.oauth2_permission_scope_ids["user_impersonation"]
  #         # user_impersonation - Allow the application full access to the Azure Key Vault service on behalf of the signed-in user (Admin consent NOT required)
  #         # matches the settings in oauth2_permission_scope - value = "user_impersonation"
  #     type = "Scope" # Delegated
  #     ##############################################################################################################################################################
  #     # The "Admin consent required" column shows the default value for an organization. However, user consent can be customized per permission, user, or app.
  #     # This column may not reflect the value in your organization, or in organizations where this app will be used.
  #     # https://go.microsoft.com/fwlink/?linkid=2152292
  #     ##############################################################################################################################################################
  #     # Azure Key Vault REST API: https://learn.microsoft.com/en-us/rest/api/keyvault/
  #   }
  # }

  # required_resource_access {
  #   resource_app_id = "00000000-0000-0000-0000-000000000000"  # Azure Key Vault
  #   resource_access {
  #     id   = "00000000-0000-0000-0000-000000000000"  # user_impersonation
  #     type = "Scope" # Delegated
  #   }
  # }

  ##################################################################################################################
  # Access to Azure Storage API with "user_impersonation" (OBO Flow)
  ##################################################################################################################
  # required_resource_access {
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureStorage
  #       # Azure Key Vault - Check thist nofficial source of application IDs https://github.com/manicminer/hamilton/blob/main/environments/published.go
  #   resource_access {
  #     id   = azuread_service_principal.storage.oauth2_permission_scope_ids["user_impersonation"]
  #         # user_impersonation - Allow the application full access to the Azure Storage service on behalf of the signed-in user (Admin consent NOT required)
  #         # matches the settings in oauth2_permission_scope - value = "user_impersonation"
  #     type = "Scope" # Delegated
  #     ##############################################################################################################################################################
  #     # The "Admin consent required" column shows the default value for an organization. However, user consent can be customized per permission, user, or app.
  #     # This column may not reflect the value in your organization, or in organizations where this app will be used.
  #     # https://go.microsoft.com/fwlink/?linkid=2152292
  #     ##############################################################################################################################################################
  #     # Azure Storage REST API Reference: https://learn.microsoft.com/en-us/rest/api/storageservices/
  #   }
  # }

  # required_resource_access {
  #   resource_app_id = "00000000-0000-0000-0000-000000000000"  # Azure Storage
  #   resource_access {
  #     id   = "00000000-0000-0000-0000-000000000000"       # user_impersonation
  #     type = "Scope"
  #   }
  # }
  ####################################################################################################################################
  # Access to Microsoft Graph API
  # https://stackoverflow.com/questions/65241844/whats-the-difference-between-user-read-vs-openid-profile-email-permissions-in-a
  # So there you have it. Add User.Read if you want to query anything from the Graph APIs,
  # else just use openid (and optionally profile email) if you are happy just signing users in and using the id_token for your needs.
  #
  # https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
  ####################################################################################################################################
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph # Microsoft Graph
    # resource_access { # Remove the default “User.Read Delegated” permissions
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]   # User.Read - Sign in and read user profile  # Microsoft Graph Procotol
    #   type = "Scope" # Delegated
    # }
    resource_access {
      # openid - Sign users in
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # OIDC Protocol
      type = "Scope"                                                                 # Delegated
    }
    resource_access {
      # Offline_access - Maintain access to data you have given it access to
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"] # OIDC Protocol
      type = "Scope"                                                                         # Delegated
    }
  }
}



########################################################################################################################################################
# Resource: azuread_application_pre_authorized
# These settings will be added to the manifest of the registered app.
# Manages client applications that are pre-authorized with the specified permissions to access an application's APIs without requiring user consent.
# https://www.hashicorp.com/blog/announcing-terraform-azuread-provider-2-0
# https://stackoverflow.com/questions/57348132/pre-authorize-application-in-azure-active-directory-hide-scope-from-other-appli
# https://learn.microsoft.com/en-us/azure/active-directory/develop/setup-multi-tenant-app
#     Understand user and admin consent and make appropriate code changes: https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-convert-app-to-be-multi-tenant
#     Multiple tiers in a single tenant:
#     This can be a problem if your logical application consists of two or more application registrations, for example a separate client and resource.
#     How do you get the resource into the customer tenant first? Azure AD covers this case by enabling client and resource to be consented in a single step.
#     The user sees the sum total of the permissions requested by both the client and resource on the consent page.
#     To enable this behavior, the resource’s application registration must include the client’s App ID as a knownClientApplications in its application manifest.
########################################################################################################################################################
resource "azuread_application_pre_authorized" "appcore_back_api" {
  application_object_id = azuread_application.appcore_back_api.object_id
  authorized_app_id     = azuread_application.appcore_front_spa.application_id
  permission_ids        = [azuread_application.appcore_back_api.oauth2_permission_scope_ids["user_impersonation"]]
  depends_on = [
    azuread_application.appcore_back_api,
    azuread_application.appcore_front_spa,
  ]
}
resource "azuread_application_pre_authorized" "applink_cloud_api" {
  application_object_id = azuread_application.applink_cloud_api.object_id
  authorized_app_id     = azuread_application.appcore_front_spa.application_id
  permission_ids        = [azuread_application.applink_cloud_api.oauth2_permission_scope_ids["General"]]
}
resource "azuread_application_pre_authorized" "appcore_back_api_applink_cloud_api" {
  application_object_id = azuread_application.applink_cloud_api.object_id
  authorized_app_id     = azuread_application.appcore_back_api.application_id
  permission_ids        = [azuread_application.applink_cloud_api.oauth2_permission_scope_ids["General"]]
}

# resource "azuread_application_pre_authorized" "applink_cloud_api" {
#   application_object_id       = azuread_application.applink_cloud_api.object_id
#   authorized_app_id           = azuread_application.appcore_front_spa.application_id
#   permission_ids              = [azuread_application.applink_cloud_api.oauth2_permission_scope_ids["user_impersonation"]]
# }
