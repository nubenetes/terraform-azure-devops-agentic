##################################################################################
# Internal Users
##################################################################################
resource "azuread_user" "internal" {
  for_each = {
    for internal_user in local.yaml_internal_users_without_roles : "${internal_user.email}" => internal_user
  }
  given_name          = each.value.first-name # (Optional) The given name (first name) of the user.
  surname             = each.value.last-name  # (Optional) The user's surname (family name or last name).
  job_title           = each.value.job-title
  city                = each.value.city
  user_principal_name = each.value.email
  company_name        = each.value.center
  display_name        = join(" ", [coalesce("${each.value.first-name}", "Name"), coalesce("${each.value.last-name}", "Surname"), "Internal App-Core User for ${each.value.center} Corporation"])
  password            = random_password.internal_user["${each.value.email}"].result
  depends_on = [
    data.azuread_group.appcore_admin_role_internal_users,
  ]
}

resource "random_password" "internal_user" {
  for_each = {
    for internal_user in local.yaml_internal_users_without_roles : "${internal_user.email}" => internal_user
  }
  length      = 10
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = false
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}
