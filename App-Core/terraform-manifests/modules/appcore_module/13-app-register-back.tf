#################################################################################################################################################
# Application registrations in Azure Active Directory for use in App-Core application that utilises OAuth2 on the Microsoft Identity Platform
# 
# App-Core Frontend is App-Core Web Application
# App-Core Backend is App-Core API Service
#################################################################################################################################################

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
# https://www.mytechramblings.com/posts/automate-azure-ad-app-registration-using-terraform/
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application

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

###############################################################################################################################
# A Node.js Web API secured by Azure AD and calling Microsoft Graph on behalf of a signed-in user:
# https://github.com/Azure-Samples/ms-identity-javascript-tutorial/blob/main/4-AdvancedGrants/1-call-api-graph/README.md
###############################################################################################################################

resource "azuread_application" "pdf_renderer" {
  display_name     = local.appr_name_pdf_renderer
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
  #   # Microsoft Graph
  #   resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  #   # resource_access { # Remove the default “User.Read Delegated” permissions
  #   #   # User.Read - Sign in and read user profile
  #   #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]   
  #   #   type = "Scope" # Delegated 
  #   # }
  #   resource_access {
  #     id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # openid - Sign users in
  #     type = "Scope"
  #   }
  #   resource_access {
  #     # Offline_access - Maintain access to data you have given it access to
  #     id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"]
  #     type = "Scope" # Delegated 
  #   }
  # }
}




