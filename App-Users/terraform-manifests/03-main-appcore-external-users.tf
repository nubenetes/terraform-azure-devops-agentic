data "azuread_user" "appcore_external" {
  for_each = {
    for external_user in local.yaml_external_users : "${external_user.email}" => external_user
  }
  user_principal_name = join("#", [replace(azuread_invitation.appcore_external_user["${each.value.email}"].user_email_address, "@", "_"), "EXT", "@enterprise.onmicrosoft.com"])
  # user_display_name = testuser1guestEnterprise
  # user_email_address = cloud-admin@example.com
  # testuser1guestEnterprise_gmail.com#EXT#@enterprise.onmicrosoft.com
  depends_on = [
    azuread_invitation.appcore_external_user,
  ]
}

data "azuread_group" "appcore_external_users" {
  for_each = {
    for external_user in local.yaml_external_users : "${external_user.email}" => external_user
  }
  display_name     = "cg-appcore-${each.value.center}-${each.value.role}_role-${each.value.env}"
  security_enabled = true
}
