# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
# https://www.mytechramblings.com/posts/automate-azure-ad-app-registration-using-terraform/
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application


# Create an application
# The following API permissions are required in order to use this resource.
# When authenticated with a service principal, this resource requires one of the following application roles: Application.ReadWrite.All or Directory.ReadWrite.All
resource "azuread_application" "App-Catalog" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  display_name = "appr-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  #logo_image       = filebase64("/path/to/logo.png")
  owners = [data.azurerm_client_config.current.object_id]
  #sign_in_audience = "AzureADMultipleOrgs"
  sign_in_audience = "AzureADMyOrg"

  # Features and Tags
  # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
  # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
  # Tag values also propagate to any linked service principals.
  feature_tags {
    enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
    gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
  }

  ##################################################################################################################
  # Request API permissions - Microsoft Graph
  # Two types of permissions:
  # - Delegated permissions (Scope): Your application needs to access the API as the signed-in user.
  # - Application permissions (Role): Your application runs as a background service or daemon without a signed-in user.
  ##################################################################################################################
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph # Microsoft Graph
    # resource_access {
    #     id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]   # User.Read - Sign in and read user profile
    #     type = "Scope" # Delegated permission
    #   }
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

  # single_page_application {
  #   # A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
  #   # https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-create-an-app-registration-in-azure-ad-for-your-app-service-app
  #   # Redirect URI (reply URL) restrictions and limitations: https://learn.microsoft.com/en-us/azure/active-directory/develop/reply-url
  #   # https://enterprise.atlassian.net/wiki/spaces/DEV/pages/00000000
  #   # https://enterprise.atlassian.net/wiki/spaces/DEV/pages/00000000
  #   redirect_uris = ["https://${each.value}-${var.dns_prefix}${local.env_generator}.${local.dns_zone}/"]
  #   # (Optional) A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
  # }
  web {
    #homepage_url  = "https://${var.client_name}.Enterprise${var.environment}.com"
    #logout_url    = "https://app.example.net/logout"
    #redirect_uris = ["https://${each.value}-${var.dns_prefix}${local.gitbranch}${local.env_generator}.${local.dns_zone}"] # Error: URI must have a trailing slash when there is no path segment
    redirect_uris = ["https://${each.value}${var.dns_prefix}${local.gitbranch}${local.env_generator}.${local.dns_zone}/"]
    implicit_grant { # Microsoft Azure Active Directory Authentication Library (ADAL)
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "time_rotating" "app" {
  rotation_days = 7
}

resource "azuread_application_password" "App-Catalog" {
  for_each              = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  display_name          = "mysecret"
  application_object_id = azuread_application.App-Catalog[each.key].object_id
  rotate_when_changed = {
    rotation = time_rotating.app.id
  }
}
