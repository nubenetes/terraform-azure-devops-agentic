##################################################################################
# AzureAD B2B external user (guest) invitations
# User Principal Names (UPN) in the format prefix#EXT#@yourtenant.onmicrosoft.com
# https://rafaelmedeiros94.medium.com/terraform-retrieving-values-from-yaml-files-ffd72b043eae
# https://learn.microsoft.com/en-us/azure/active-directory/external-identities/faq
##################################################################################

resource "azuread_group_member" "appcore_external_user" {
  for_each = {
    for external_user in local.yaml_external_users : "${external_user.email}" => external_user
  }
  group_object_id  = data.azuread_group.appcore_external_users["${each.value.email}"].id
  member_object_id = data.azuread_user.appcore_external["${each.value.email}"].object_id
  depends_on = [
    data.azuread_group.appcore_external_users,
    data.azuread_user.appcore_external,
  ]
}
