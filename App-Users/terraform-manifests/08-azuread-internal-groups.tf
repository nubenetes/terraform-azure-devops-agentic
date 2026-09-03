##################################################################################
# Groups with internal users
##################################################################################

resource "azuread_group_member" "appcore_internal_admin_user" {
  for_each = {
    for internal_admin_user in local.yaml_internal_users : "${internal_admin_user.email}.${internal_admin_user.appcore-admin-role-key}" => internal_admin_user
    if internal_admin_user.appcore-admin-role != null
  }
  group_object_id  = data.azuread_group.appcore_admin_role_internal_users["${each.value.email}.${each.value.appcore-admin-role-key}"].id
  member_object_id = data.azuread_user.internal["${each.value.email}"].object_id
  depends_on = [
    data.azuread_group.appcore_admin_role_internal_users,
    data.azuread_user.internal,
  ]
}

resource "azuread_group_member" "appcore_internal_user" {
  for_each = {
    for internal_user in local.yaml_internal_users : "${internal_user.email}.${internal_user.appcore-user-role-key}" => internal_user
    if internal_user.appcore-user-role != null
  }

  group_object_id  = data.azuread_group.appcore_user_role_internal_users["${each.value.email}.${each.value.appcore-user-role-key}"].id
  member_object_id = data.azuread_user.internal["${each.value.email}"].object_id
  depends_on = [
    data.azuread_group.appcore_user_role_internal_users,
    data.azuread_user.internal,
  ]
}
