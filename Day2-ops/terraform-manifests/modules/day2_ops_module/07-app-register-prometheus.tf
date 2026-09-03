# https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/azuread/

# resource "azuread_application" "prometheus_login" {
#   display_name        = local.appr_name_prometheus_login
#   owners              = [data.azurerm_client_config.current.object_id]
#   #sign_in_audience   = "AzureADMultipleOrgs"
#   sign_in_audience    = "AzureADMyOrg"
#   #logo_image         = filebase64("/path/to/logo.png")
#   #tags               = local.tags  # Cannot be used together with the feature_tags property

#   # Features and Tags
#   # Features are configured for an application using tags, and are provided as a shortcut to set the corresponding magic tag value for each feature.
#   # You cannot configure feature_tags and tags for an application at the same time, so if you need to assign additional custom tags it's recommended to use the tags property instead.
#   # Tag values also propagate to any linked service principals.
#   feature_tags {
#     enterprise = true # (Optional) Whether this application represents an Enterprise Application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag.
#     gallery    = true # (Optional) Whether this application represents a gallery application for linked service principals. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag.
#   }
#   api {
#     requested_access_token_version = 2
#   }
#   ####################################################################################################################################
#   # Access to Microsoft Graph API
#   # https://stackoverflow.com/questions/65241844/whats-the-difference-between-user-read-vs-openid-profile-email-permissions-in-a
#   # So there you have it. Add User.Read if you want to query anything from the Graph APIs,
#   # else just use openid (and optionally profile email) if you are happy just signing users in and using the id_token for your needs.
#   #
#   # https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
#   ####################################################################################################################################
#   required_resource_access {
#     resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph # Microsoft Graph
#     resource_access {
#       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # OIDC Protocol
#       type = "Scope" # Delegated
#     }
#     resource_access {
#       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"]
#       type = "Scope" # Delegated
#     }
#     resource_access {
#       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
#         # Required by oauthproxy.go in grafana helm chart. We get this error without this permission:
#         # Error creating session during OAuth2 callback: unable to get groups from Microsoft Graph: unable to unmarshal Microsoft Graph response: unexpected status "403"
#       type = "Scope" # Delegated
#     }
#     resource_access {
#       id   = azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
#       # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
#       # Required by oauthproxy.go . Without this permission we get a 500 error on the browser:
#       # could not get claim "groups": failed to fetch claims from profile URL
#       # REMEMBER to Grant Admin Consent permission on Azure Portal UI !!
#       type = "Role" # Application
#     }
#   }
#   required_resource_access {
#     resource_app_id = "00000000-0000-0000-0000-000000000000" # Azure Kubernetes Service AAD Server
#     resource_access {
#       id   = "00000000-0000-0000-0000-000000000000" # user.read
#       type = "Scope" # Delegated
#     }
#   }
#   ################
#   # SPA settings:
#   ################
#   # Configure your App Service to use Azure AD login:
#   #  https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad
#   # Solution: "https://${local.app_name_appcore_front_spa}.azurewebsites.net/.auth/login/aad/callback"
#   # single_page_application {
#   #   # A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
#   #   # https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-create-an-app-registration-in-azure-ad-for-your-app-service-app
#   #   # Redirect URI (reply URL) restrictions and limitations: https://learn.microsoft.com/en-us/azure/active-directory/develop/reply-url
#   #   redirect_uris = ["https://prometheus.${local.environment}.enterprise.com/oauth2/callback"]
#   #   # (Optional) A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL.
#   # }
#   #######################################################################################################################################
#   # Web - Implicit grant and hybrid flows, enable ID tokens to allow OpenID Connect user sign-ins from App Service (but we use MSAL!).
#   #######################################################################################################################################
#   web {
#     redirect_uris = ["https://prometheus.${local.dns_child_zone}.enterprise.com/login/azuread","https://prometheus.${local.dns_child_zone}.enterprise.com/"]
#   }
# }


# #################
# # Time Rotating
# #################
# resource "time_rotating" "prometheus" {
#   rotation_days = 7
# }

# ##############
# # Secrets
# ##############
# resource "azuread_application_password" "prometheus_login" {
#   display_name          = "prometheus-auth-proxy-secret"
#   application_object_id = azuread_application.prometheus_login.object_id
#   rotate_when_changed = {
#     rotation = time_rotating.prometheus.id
#   }
# }
