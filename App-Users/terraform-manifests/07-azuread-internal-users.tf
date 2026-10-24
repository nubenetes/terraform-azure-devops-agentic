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
  user_principal_name = can(regex("@", each.value.email)) ? each.value.email : "${each.value.email}@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  company_name        = each.value.center
  display_name        = join(" ", [coalesce("${each.value.first-name}", "Name"), coalesce("${each.value.last-name}", "Surname"), "Internal App-Core User for ${each.value.center} Corporation"])
  password            = random_password.internal[each.value.email].result
  depends_on = [
    data.azuread_group.appcore_admin_role_internal_users,
  ]
}

resource "random_password" "internal" {
  for_each = {
    for internal_user in local.yaml_internal_users_without_roles : "${internal_user.email}" => internal_user
  }
  length      = 16
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = true
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

check "entra_verified_domains" {
  assert {
    condition     = length(data.azuread_domains.aad_domains.domains) > 0
    error_message = "At least one verified initial domain must exist in the Microsoft Entra ID tenant."
  }
}

