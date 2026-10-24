data "azuread_user" "manually_provisioned" {
  for_each = {
    for internal_user in local.load_yaml_manually_provisioned_internal_users : "${internal_user.email}" => internal_user
  }
  user_principal_name = can(regex("@", each.value.email)) ? each.value.email : "${each.value.email}@${data.azuread_domains.aad_domains.domains[0].domain_name}"
}

data "azuread_group" "appcore_admin_role_internal_users" {
  for_each = {
    for internal_user in concat(local.yaml_internal_users, local.yaml_manually_provisioned_internal_users) : "${internal_user.email}.${internal_user.appcore-admin-role-key}" => internal_user
    if internal_user.appcore-admin-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-admin_role-${each.value.appcore-admin-role}"
  security_enabled = true
}

data "azuread_group" "appcore_user_role_internal_users" {
  for_each = {
    for internal_user in concat(local.yaml_internal_users, local.yaml_manually_provisioned_internal_users) : "${internal_user.email}.${internal_user.appcore-user-role-key}" => internal_user
    if internal_user.appcore-user-role != null
  }
  display_name     = "cg-appcore-${each.value.center}-user_role-${each.value.appcore-user-role}"
  security_enabled = true
}

data "azuread_group" "app-analysis_admin" {
  for_each = {
    for internal_user in concat(local.yaml_internal_users, local.yaml_manually_provisioned_internal_users) : "${internal_user.email}.${internal_user.app-analysis-admin-role-key}" => internal_user
    if internal_user.app-analysis-admin-role != null
  }
  display_name     = "cg-app-analysis-${each.value.center}-admin_role-${each.value.app-analysis-admin-role}"
  security_enabled = true
}

data "azuread_group" "app-analysis_users" {
  for_each = {
    for internal_user in concat(local.yaml_internal_users, local.yaml_manually_provisioned_internal_users) : "${internal_user.email}.${internal_user.app-analysis-user-role-key}" => internal_user
    if internal_user.app-analysis-user-role != null
  }
  display_name     = "cg-app-analysis-${each.value.center}-user_role-${each.value.app-analysis-user-role}"
  security_enabled = true
}

