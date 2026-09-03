data "azuread_user" "internal" {
  for_each = {
    for internal_user in local.yaml_internal_users_without_roles : "${internal_user.email}" => internal_user
  }
  user_principal_name = azuread_user.internal["${each.value.email}"].user_principal_name
  depends_on = [
    azuread_user.internal,
  ]
}
data "azuread_group" "appcore_admin_role_internal_users" {
  for_each = {
    for internal_user in local.yaml_internal_users : "${internal_user.email}.${internal_user.appcore-admin-role-key}" => internal_user
    if internal_user.appcore-admin-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-admin_role-${each.value.appcore-admin-role}"
  security_enabled = true
}

data "azuread_group" "appcore_user_role_internal_users" {
  for_each = {
    for internal_user in local.yaml_internal_users : "${internal_user.email}.${internal_user.appcore-user-role-key}" => internal_user
    if internal_user.appcore-user-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-user_role-${each.value.appcore-user-role}"
  security_enabled = true
}
