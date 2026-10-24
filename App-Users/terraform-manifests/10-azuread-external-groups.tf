##################################################################################
# AzureAD B2B external user (guest) invitations
# User Principal Names (UPN) in the format prefix#EXT#@yourtenant.onmicrosoft.com
# https://rafaelmedeiros94.medium.com/terraform-retrieving-values-from-yaml-files-ffd72b043eae
# https://learn.microsoft.com/en-us/azure/active-directory/external-identities/faq
##################################################################################

resource "azuread_group_member" "external" {
  for_each = {
    for external_user in local.yaml_external_users : "${external_user.email}-${external_user.env}-${external_user.role}-${external_user.client}" => external_user
  }
  group_object_id  = data.azuread_group.external_users[each.key].id
  member_object_id = azuread_invitation.external[each.value.email].user_id
  depends_on = [
    data.azuread_group.external_users,
    azuread_invitation.external,
  ]
}

