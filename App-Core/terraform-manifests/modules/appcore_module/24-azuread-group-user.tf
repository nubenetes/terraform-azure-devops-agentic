# Nested for_each/loops in terraform:
# https://www.daveperrett.com/articles/2000/01/01/nested-for-each-with-terraform/

###############################################################################################################################################################
# UsersClient.BaseClient.Post(): unexpected status 403 with OData error:  Authorization_RequestDenied: Insufficient privileges to complete the operation.
# Solved by adding sp-appcore-Enterprise-dev to "management level" - "User Administrator" Role
# https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/00000000-0000-0000-0000-000000000000/roleId/00000000-0000-0000-0000-000000000000/roleTemplateId/00000000-0000-0000-0000-000000000000/roleName/User%20administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/00000000-0000-0000-0000-000000000000
#
# UsersClient.BaseClient.Post(): unexpected status 400 with OData error: Request_BadRequest: The domain portion of the userPrincipalName property is invalid. You must use one of the verified domain names in your organization.
# Solution: Add Custom domain Name in https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Domains :
# https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/add-custom-domain
#
# eng.enterprise.com
# subdomains like core.eng.enterprise.com are required (DNS MX aka e-mail)
###############################################################################################################################################################

###############################################################################################################################################################
# Using Terraform to create an azure active directory custom domain
# Unfortunately, there is no support yet for custom domain creation using the azuread provider within Terraform.
# https://stackoverflow.com/questions/69774110/using-terraform-to-create-an-azure-active-directory-custom-domain
###############################################################################################################################################################

################################################################################
# Group with dynamic membership
# https://learn.microsoft.com/en-gb/azure/active-directory/enterprise-users/groups-dynamic-membership
# resource "azuread_group" "example" {
#   display_name     = "MyGroup"
#   owners           = [data.azuread_client_config.current.object_id]
#   security_enabled = true
#   types            = ["DynamicMembership"]

#   dynamic_membership {
#     enabled = true
#     rule    = "user.department -eq \"Sales\""
#   }
# }
###################################################################################

resource "azuread_group" "appcore_admin_role" {
  for_each                = toset(var.client_names)
  display_name            = "cg-appcore-${each.value}-admin_role-${local.instance_environment}"
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true
  security_enabled        = true
  #members                 = tolist(data.azuread_users.list_of_test_users.users)
}

resource "azuread_group" "appcore_user_role" {
  for_each                = toset(var.client_names)
  display_name            = "cg-appcore-${each.value}-user_role-${local.instance_environment}"
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true
  security_enabled        = true
  #members                 = tolist(data.azuread_users.list_of_test_users.users)
}

resource "azuread_user" "testuser1" {
  #for_each                    = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each                    = toset(var.client_names)
  user_principal_name         = "${var.testuser1}-appcore-${each.value}-${local.gitbranch}${var.location_code}${var.environment}@${var.dns_parent_zone}"
  display_name                = "${var.testuser1}-appcore-${each.value}-${local.instance_environment}"
  cost_center                 = "C1234" # Example (Optional)
  department                  = "R&D"
  division                    = "Cloud"
  disable_password_expiration = false
  password                    = random_password.testuser1[each.key].result
  depends_on = [
    azuread_group.appcore_user_role,
  ]
}
resource "azuread_user" "testadmin" {
  #for_each                    = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each                    = toset(var.client_names)
  user_principal_name         = "${var.testadmin}-appcore-${each.value}-${local.gitbranch}${var.location_code}${var.environment}@${var.dns_parent_zone}"
  display_name                = "${var.testadmin}-appcore-${each.value}-${local.instance_environment}"
  cost_center                 = "C1234" # Example (Optional)
  department                  = "R&D"
  division                    = "Cloud"
  disable_password_expiration = false
  password                    = random_password.testadmin[each.key].result
  depends_on = [
    azuread_group.appcore_admin_role,
  ]
}

data "azuread_user" "testuser1" {
  #for_each            = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each            = toset(var.client_names)
  user_principal_name = azuread_user.testuser1[each.key].user_principal_name
  depends_on = [
    azuread_user.testuser1,
  ]
}

data "azuread_user" "testadmin" {
  #for_each            = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each            = toset(var.client_names)
  user_principal_name = azuread_user.testadmin[each.key].user_principal_name
  depends_on = [
    azuread_user.testadmin,
  ]
}

resource "azuread_group_member" "testuser1" {
  #for_each          = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each         = toset(var.client_names)
  group_object_id  = azuread_group.appcore_user_role[each.key].id
  member_object_id = data.azuread_user.testuser1[each.key].id
  depends_on = [
    azuread_group.appcore_user_role,
    azuread_user.testuser1,
  ]
}

resource "azuread_group_member" "testadmin" {
  # for_each          = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
  for_each         = toset(var.client_names)
  group_object_id  = azuread_group.appcore_admin_role[each.key].id
  member_object_id = data.azuread_user.testadmin[each.key].id
  depends_on = [
    azuread_group.appcore_admin_role,
    azuread_user.testadmin,
  ]
}
