data "azuread_user" "manually_provisioned_internal" {
  for_each = {
    for manually_provisioned_internal_user in local.list_manually_provisioned_internal_users_with_custom_security_attributes : "${manually_provisioned_internal_user.upn}" => manually_provisioned_internal_user
  }
  user_principal_name = each.value.upn
}
data "azuread_group" "appcore_admin_role_manually_provisioned_internal_users" {
  for_each = {
    for manually_provisioned_internal_user in local.yaml_manually_provisioned_internal_users : "${manually_provisioned_internal_user.email}.${manually_provisioned_internal_user.appcore-admin-role-key}" => manually_provisioned_internal_user
    if manually_provisioned_internal_user.appcore-admin-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-admin_role-${each.value.appcore-admin-role}"
  security_enabled = true
}

data "azuread_group" "appcore_user_role_manually_provisioned_internal_users" {
  for_each = {
    for manually_provisioned_internal_user in local.yaml_manually_provisioned_internal_users : "${manually_provisioned_internal_user.email}.${manually_provisioned_internal_user.appcore-user-role-key}" => manually_provisioned_internal_user
    if manually_provisioned_internal_user.appcore-user-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-user_role-${each.value.appcore-user-role}"
  security_enabled = true
}
