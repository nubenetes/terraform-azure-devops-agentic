##################################################################################
# Groups with manually provisioned internal users
##################################################################################

resource "azuread_group_member" "appcore_manually_provisioned_internal_admin_user" {
  for_each = {
    for manually_provisioned_internal_admin_user in local.yaml_manually_provisioned_internal_users : "${manually_provisioned_internal_admin_user.email}.${manually_provisioned_internal_admin_user.appcore-admin-role-key}" => manually_provisioned_internal_admin_user
    if manually_provisioned_internal_admin_user.appcore-admin-role != null
  }
  group_object_id  = data.azuread_group.appcore_admin_role_manually_provisioned_internal_users["${each.value.email}.${each.value.appcore-admin-role-key}"].id
  member_object_id = data.azuread_user.manually_provisioned_internal["${each.value.email}"].object_id
  depends_on = [
    data.azuread_group.appcore_admin_role_manually_provisioned_internal_users,
    data.azuread_user.manually_provisioned_internal,
  ]
}

resource "azuread_group_member" "appcore_manually_provisioned_internal_user" {
  for_each = {
    for manually_provisioned_internal_user in local.yaml_manually_provisioned_internal_users : "${manually_provisioned_internal_user.email}.${manually_provisioned_internal_user.appcore-user-role-key}" => manually_provisioned_internal_user
    if manually_provisioned_internal_user.appcore-user-role != null
  }

  group_object_id  = data.azuread_group.appcore_user_role_manually_provisioned_internal_users["${each.value.email}.${each.value.appcore-user-role-key}"].id
  member_object_id = data.azuread_user.manually_provisioned_internal["${each.value.email}"].object_id
  depends_on = [
    data.azuread_group.appcore_user_role_manually_provisioned_internal_users,
    data.azuread_user.manually_provisioned_internal,
  ]
}
