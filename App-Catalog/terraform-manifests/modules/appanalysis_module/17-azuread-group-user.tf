# Nested for_each/loops in terraform:
# https://www.daveperrett.com/articles/2000/01/01/nested-for-each-with-terraform/


###############################################################################################################################################################
# UsersClient.BaseClient.Post(): unexpected status 403 with OData error:  Authorization_RequestDenied: Insufficient privileges to complete the operation.
# Solved by adding sp-app-analysis-Enterprise-dev to "management level" - "User Administrator" Role
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

# resource "azuread_group" "appanalysis_admin_role" {
#   for_each                 = toset(var.client_names)
#   display_name             = "cg-cata-${each.value}-admin_role-${local.instance_environment}"
#   owners                   = [data.azuread_client_config.current.object_id]
#   prevent_duplicate_names  = true
#   security_enabled         = true
#   #members                 = tolist(data.azuread_users.list_of_test_users.users)
# }
# resource "azuread_group" "appanalysis_user_role" {
#   for_each                 = toset(var.client_names)
#   display_name             = "cg-cata-${each.value}-user_role-${local.instance_environment}"
#   owners                   = [data.azuread_client_config.current.object_id]
#   prevent_duplicate_names  = true
#   security_enabled         = true
#   #members                 = tolist(data.azuread_users.list_of_test_users.users)
# }

# resource "azuread_group_member" "test_user1" {
#   for_each          = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#   group_object_id   = azuread_group.appanalysis_user_role[each.key].id
#   member_object_id  = data.azuread_user.test_user1[each.key].id
# }

# resource "azuread_group_member" "test_admin" {
#   for_each          = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#   group_object_id   = azuread_group.appanalysis_admin_role[each.key].id
#   member_object_id  = data.azuread_user.test_admin[each.key].id
# }

########################################################################
# One user per client and environment - examples:
# developer@enterprise.com
# admin@enterprise.com
#
# developer@enterprise.com
# admin@enterprise.com
########################################################################

# resource "azuread_user" "test_user1" {
#     for_each                    = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#     user_principal_name         = "${var.test_user1}-cata-${each.value}-${local.gitbranch}${var.environment}@${var.dns_parent_zone}"
#     display_name                = "${var.test_user1}-cata-${each.value}-${local.instance_environment}"
#     cost_center                 = "C1234"  # Example (Optional)
#     department                  = "R&D"
#     division                    = "Cloud"
#     disable_password_expiration = false
#     password                    = random_password.test_user1.result
# }
# resource "azuread_user" "test_admin" {
#     for_each                    = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#     user_principal_name         = "${var.test_admin}-cata-${each.value}-${local.gitbranch}${var.environment}@${var.dns_parent_zone}"
#     display_name                = "${var.test_admin}-cata-${each.value}-${local.instance_environment}"
#     cost_center                 = "C1234"  # Example (Optional)
#     department                  = "R&D"
#     division                    = "Cloud"
#     disable_password_expiration = false
#     password                    = random_password.test_admin.result
# }

# data "azuread_user" "test_user1" {
#   for_each            = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#   user_principal_name = azuread_user.test_user1[each.key].user_principal_name
#   depends_on = [
#     azuread_user.test_user1,
#   ]
# }

# data "azuread_user" "test_admin" {
#   for_each            = (var.environment != "pro") ? toset(var.client_names):[]  # We don't want test users on Production
#   user_principal_name = azuread_user.test_admin[each.key].user_principal_name
#   depends_on = [
#     azuread_user.test_admin,
#   ]
# }
