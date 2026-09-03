#################################################################################################################################################
# Application registrations in Azure Active Directory for use in App-Core application that utilises OAuth2 on the Microsoft Identity Platform
#
# App-Core Frontend is App-Core Web Application
# App-Core Backend is App-Core API Service
#################################################################################################################################################

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
# https://www.mytechramblings.com/posts/automate-azure-ad-app-registration-using-terraform/
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application

# Quickstart Register App:
# https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app

###############################################################################################
# Implicit Flow example:
# https://github.com/hashicorp/terraform-provider-azuread/tree/main/examples/application
###############################################################################################

##################################################################################################################
# Request API permissions - Microsoft Graph
# Two types of permissions:
# - Delegated permissions (Scope): Your application needs to access the API as the signed-in user.
# - Application permissions (Role): Your application runs as a background service or daemon without a signed-in user.
##################################################################################################################

####################################################################################################################################################################################
# A Node.js Web API secured by Azure AD and calling Microsoft Graph on behalf of a signed-in user:
# https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md
#
# If the Client is a Single-Page App (SPA), an application running in a browser using a scripting language like JavaScript, there are two grant options:
# the Authorization Code Flow with Proof Key for Code Exchange (PKCE) and the Implicit Flow with Form Post.
# For most cases, we recommend using the Authorization Code Flow with PKCE because the Access Token is not exposed on the client side, and this flow can return Refresh Tokens
####################################################################################################################################################################################

####################################################################################################################################################################################
# Example of OAuth 2.0 Authorization Code Flow + PKCE for Single Page Applications
# At the time these articles were written, the recommended flow for Single Page Applications was Implicit Flow,
# but for quite some time now, the recommendation has been the same as for native applications: the Authorization Code + PKCE flow.
# This section demonstrates how it works with these types of applications.
# https://www.returngis.net/2022/12/ejemplo-de-authorization-code-flow-pkce-de-oauth-2-0-para-single-page-applications/
####################################################################################################################################################################################

# Create an application
# The following API permissions are required in order to use this resource.
# When authenticated with a service principal, this resource requires one of the following application roles: Application.ReadWrite.All or Directory.ReadWrite.All
resource "azuread_application" "appcore_front_spa" {
  display_name = local.appr_name_appcore_front_spa
  owners       = [data.azurerm_client_config.current.object_id]
  #sign_in_audience   = "AzureADMultipleOrgs"
  sign_in_audience = "AzureADMyOrg"
  #logo_image         = filebase64("/path/to/logo.png")
  #tags               = local.tags  # Cannot be used together with the feature_tags property

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }
  # required_resource_access {
  #   resource_app_id = azuread_application.appcore_back_api.application_id
  #   dynamic "resource_access" {
  #     for_each = azuread_application.appcore_back_api.api.0.oauth2_permission_scope
  #     iterator = scope
  #     content {
  #       id   = scope.value.id
  #       type = "Scope" # Delegated
  #     }
  #   }
  # }
  # required_resource_access {
  #   resource_app_id = azuread_application.applink_cloud_api.application_id
  #   dynamic "resource_access" {
  #     for_each = azuread_application.applink_cloud_api.api.0.oauth2_permission_scope
  #     iterator = scope
  #     content {
  #       id   = scope.value.id
  #       type = "Scope" # Delegated
  #     }
  #   }
  # }
  required_resource_access {
    # Azure Key Vault
    resource_app_id = "00000000-0000-0000-0000-000000000000"
    resource_access {
      # user_impersonation
      id   = "00000000-0000-0000-0000-000000000000"
      type = "Scope" # Delegated
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
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph # Microsoft Graph
    # resource_access {                                                                             # Remove the default “User.Read Delegated” permissions
    #   # User.Read - Sign in and read user profile
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"] # Microsoft Graph Procotol
    #   type = "Scope" # Delegated
    # }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # OIDC Protocol
      type = "Scope"                                                                 # Delegated
    }
    # resource_access {
    #   # User.Read - Sign in and read user profile
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"] # Microsoft Graph Procotol
    #   type = "Scope" # Delegated
    # }
    resource_access {
      # Offline_access - Maintain access to data you have given it access to
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"] # OIDC Protocol
      type = "Scope"                                                                         # Delegated
    }
  }
  ################
  # SPA settings:
  ################
  # Configure your App Service to use Azure AD login:
  #  https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad
  # Solution: "https://${local.app_name_appcore_front_spa}.azurewebsites.net/.auth/login/aad/callback"
  single_page_application {
    # A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
    # https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-create-an-app-registration-in-azure-ad-for-your-app-service-app
    # Redirect URI (reply URL) restrictions and limitations: https://learn.microsoft.com/en-us/azure/active-directory/develop/reply-url
    #redirect_uris = concat(["https://${local.appcore_fqdn}/","https://${local.appcore_fqdn}/core","https://${local.appcore_fqdn}/pvf","https://${local.app_name_appcore_back_api}.azurewebsites.net/.auth/login/aad/callback","https://${local.app_name_applink_cloud_api}.azurewebsites.net/.auth/login/aad/callback"],local.list_of_client_login_pages)
    redirect_uris = concat(["https://${local.appcore_fqdn}/", "https://${local.appcore_fqdn}/login", "https://${local.appcore_fqdn}/core", "https://${local.app-analysis_viewer_dns_name}/pvf"], local.list_of_client_pages, local.list_of_client_login_pages, local.list_redirect_uris_debug_appcore_front_spa_nedev)
    # (Optional) A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
  }
  #######################################################################################################################################
  # Other SPA Settings ('web' block):
  # Web - Implicit grant and hybrid flows, enable ID tokens to allow OpenID Connect user sign-ins from App Service (but we use MSAL!).
  #######################################################################################################################################
  # web {
  #   #homepage_url  = "https://${local.appcore_fqdn}/"  # Home page or landing page of the application.
  #   #logout_url    = "https://${local.appcore_fqdn}/logout"  # The URL that will be used by Microsoft's authorization service to sign out a user using front-channel, back-channel or SAML logout protocols.
  #   implicit_grant {
  #     # Implicit grant and hybrid flows
  #     # Request a token directly from the authorization endpoint. If the application has a single-page architecture (SPA) and doesn't use the authorization code flow, or if it invokes a web API via JavaScript,
  #     # select both access tokens and ID tokens. For ASP.NET Core web apps and other web apps that use hybrid authentication, select only ID tokens.
  #     # https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
  #     access_token_issuance_enabled = true # Whether this web application can request an access token using OAuth 2.0 implicit flow
  #     id_token_issuance_enabled     = true # Whether this web application can request an ID token using OAuth 2.0 implicit flow
  #   }
  # }
}


resource "azuread_application" "app-analysis_viewer_front_spa" {
  display_name     = local.appr_name_analysis_viewer_front_spa
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }
  # required_resource_access {
  #    resource_app_id =  azuread_application.app-analysis_viewer_back_api_myclient.application_id # appr-viewer-backend
  #   resource_access {
  #     id   = "00000000-0000-0000-0000-000000000000" # access_as_user
  #     type = "Scope"
  #   }
  # }

  dynamic "required_resource_access" {
    for_each = var.client_names
    iterator = viewer_instance
    content {
      resource_app_id = azuread_application.app-analysis_viewer_back_api_myclient[viewer_instance.value].application_id # appr-viewer-backend
      dynamic "resource_access" {
        for_each = azuread_application.app-analysis_viewer_back_api_myclient[viewer_instance.value].api.0.oauth2_permission_scope
        iterator = scope
        content {
          id   = scope.value.id
          type = "Scope"
        }
      }
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
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph # Microsoft Graph
    # resource_access {                                                                             # Remove the default “User.Read Delegated” permissions
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]    # User.Read - Sign in and read user profile   # Microsoft Graph Procotol
    #   type = "Scope"
    # }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # OIDC Protocol
      type = "Scope"
    }
    resource_access {
      # Offline_access - Maintain access to data you have given it access to
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"] # OIDC Protocol
      type = "Scope"                                                                         # Delegated
    }
  }
  ################
  # SPA settings:
  ################
  single_page_application {
    #redirect_uris = concat(["https://${local.appcore_fqdn}/","https://${local.appcore_fqdn}:4200/"],local.list_of_viewers_4200,local.list_of_app-analysis_viewer_back_redirect_uris)
    redirect_uris = concat(["https://${local.appcore_fqdn}/", "https://${local.app-analysis_viewer_dns_name}/"], local.list_of_viewers_redirect_uris)
  }
  #######################################################################################################################################
  # Other SPA Settings ('web' block):
  # Web - Implicit grant and hybrid flows, enable ID tokens to allow OpenID Connect user sign-ins from App Service (but we use MSAL!).
  #######################################################################################################################################
  web {
    implicit_grant {
      # Implicit grant and hybrid flows
      # Request a token directly from the authorization endpoint. If the application has a single-page architecture (SPA) and doesn't use the authorization code flow, or if it invokes a web API via JavaScript,
      # select both access tokens and ID tokens. For ASP.NET Core web apps and other web apps that use hybrid authentication, select only ID tokens.
      # https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow
      access_token_issuance_enabled = true # Whether this web application can request an access token using OAuth 2.0 implicit flow
      id_token_issuance_enabled     = true # Whether this web application can request an ID token using OAuth 2.0 implicit flow
    }
  }
}
