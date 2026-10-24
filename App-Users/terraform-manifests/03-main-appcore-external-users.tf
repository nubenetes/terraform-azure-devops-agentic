data "azuread_group" "external_users" {
  for_each = {
    for external_user in local.yaml_external_users : "${external_user.email}-${external_user.env}-${external_user.role}-${external_user.client}" => external_user
  }
  display_name     = "cg-appcore-${each.value.center}-${each.value.role}_role-${each.value.env}"
  security_enabled = true
}

