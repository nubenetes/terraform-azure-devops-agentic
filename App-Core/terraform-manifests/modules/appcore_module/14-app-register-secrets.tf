#################
# Time Rotating
#################
resource "time_rotating" "app" {
  rotation_days = 7
}

##############
# Secrets
##############
# resource "azuread_application_password" "appcore_front_spa" {
#   display_name          = "mysecret" 
#   application_object_id = azuread_application.appcore_front_spa.object_id
#   rotate_when_changed = {
#     rotation = time_rotating.app.id
#   }
# }
resource "azuread_application_password" "appcore_back_api" {
  display_name          = "mysecret"
  application_object_id = azuread_application.appcore_back_api.object_id
  rotate_when_changed = {
    rotation = time_rotating.app.id
  }
}
resource "azuread_application_password" "applink_cloud_api" {
  display_name          = "mysecret"
  application_object_id = azuread_application.applink_cloud_api.object_id
  rotate_when_changed = {
    rotation = time_rotating.app.id
  }
}
resource "azuread_application_password" "app-analysis_viewer_back_api_myclient" {
  for_each              = toset(var.client_names)
  display_name          = "mysecret"
  application_object_id = azuread_application.app-analysis_viewer_back_api_myclient[each.key].object_id
  rotate_when_changed = {
    rotation = time_rotating.app.id
  }
}















