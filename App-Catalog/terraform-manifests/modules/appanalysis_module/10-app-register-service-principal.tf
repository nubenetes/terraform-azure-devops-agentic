# Create service principals

##################################################################################
# data source for OAuthPermissions and/or Azure Common APIs
# https://github.com/hashicorp/terraform-provider-azuread/issues/250
##################################################################################

resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

# Create a service principal
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "App-Catalog" {
  for_each       = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  application_id = azuread_application.App-Catalog[each.key].application_id
  #app_role_assignment_required  = true #  (Optional) Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false.
  owners = [data.azurerm_client_config.current.object_id]
  feature_tags {
    hide = true
  }
}
