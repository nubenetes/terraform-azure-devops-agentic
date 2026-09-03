###############################
# Create a service principal
###############################
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal


########################################################################################################################################
# data source for OAuthPermissions and/or Azure Common APIs
# azuread_application_published_app_ids
# Look up an app ID for a resource/service
# https://github.com/hashicorp/terraform-provider-azuread/issues/250
#
# https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
#    This data source uses an unofficial source of application IDs, as there is currently no available official indexed source for applications or APIs published by Microsoft:
#    https://github.com/manicminer/hamilton/blob/main/environments/published.go
#
# https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/resources/service_principal.md
########################################################################################################################################
resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
  # (Optional) When true, any existing service principal linked to the same application will be automatically imported.
  # When false, an import error will be raised for any pre-existing service principal.
}

##################################
# Frotends - SPA
##################################
resource "azuread_service_principal" "appcore_front_spa" {
  application_id               = azuread_application.appcore_front_spa.application_id
  app_role_assignment_required = false
  # (Optional) Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false
  owners = [data.azurerm_client_config.current.object_id]
}
resource "azuread_service_principal" "app-analysis_viewer_front_spa" {
  application_id               = azuread_application.app-analysis_viewer_front_spa.application_id
  app_role_assignment_required = false
  # (Optional) Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false
  owners = [data.azurerm_client_config.current.object_id]
}

##################################
# Backends - API
##################################
resource "azuread_service_principal" "appcore_back_api" {
  application_id               = azuread_application.appcore_back_api.application_id
  app_role_assignment_required = true
  owners                       = [data.azurerm_client_config.current.object_id]
}
resource "azuread_service_principal" "app-analysis_viewer_back_api_myclient" {
  for_each                     = toset(var.client_names)
  application_id               = azuread_application.app-analysis_viewer_back_api_myclient[each.key].application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}
resource "azuread_service_principal" "applink_cloud_api" {
  application_id               = azuread_application.applink_cloud_api.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

##################################
# Backend - PDF Renderer
##################################
resource "azuread_service_principal" "pdf_renderer" {
  application_id               = azuread_application.pdf_renderer.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

#####################################################################################################################################
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_delegated_permission_grant
#####################################################################################################################################
# resource "azuread_service_principal_delegated_permission_grant" "appcore_back_api" {
#   service_principal_object_id          = azuread_service_principal.appcore_back_api.object_id
#   resource_service_principal_object_id = azuread_service_principal.msgraph.object_id
#   claim_values                         = ["openid", "User.Read.All"]
# }
