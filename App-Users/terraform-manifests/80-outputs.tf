####################################################################################################################################################################
# Create Outputs
#
# https://spacelift.io/blog/terraform-output
# "terraform ouput -json": This is quite useful when we want to pass the outputs to other tools for automation since JSON is way easier to handle programmatically.
# Note that Terraform does not protect sensitive output values when using the -json flag.
####################################################################################################################################################################

####################################
# data.azurerm_client_config
####################################
output "myAzureSubscription" {
  value = data.azurerm_client_config.current.subscription_id
}
output "myAzureTenantId" {
  value = data.azurerm_client_config.current.tenant_id
}

####################################
# Enterprise
####################################
output "Enterprise_product" {
  value = var.Enterprise_product
}

#############################
# gitbranch
#############################
output "gitbranch" {
  value = local.gitbranch
}

##############################################
# External Users
##############################################
output "external_users" {
  value = local.yaml_external_users
}
output "list_of_external_users_redirect_url" {
  value = jsondecode(jsonencode(tomap(merge(
    { for external_user in local.yaml_external_users : azuread_invitation.appcore_external_user["${external_user.email}"].user_email_address => azuread_invitation.appcore_external_user["${external_user.email}"].redirect_url }
  ))))
  sensitive = true
}
output "list_external_users_with_custom_security_attributes" {
  value = local.list_external_users_with_custom_security_attributes
}
##############################################
# Internal Users
##############################################
output "internal_users_without_roles" {
  value = local.yaml_internal_users_without_roles
}
output "internal_users" {
  value = local.yaml_internal_users
}
output "list_internal_users_with_custom_security_attributes" {
  value = local.list_internal_users_with_custom_security_attributes
}
output "list_of_internal_users_credentials" {
  value = jsondecode(jsonencode(tomap(merge(
    { for internal_user in local.yaml_internal_users_without_roles : azuread_user.internal["${internal_user.email}"].user_principal_name => azuread_user.internal["${internal_user.email}"].password }
  ))))
  sensitive = true
}

##############################################
# Manually Provisioned Internal Users
##############################################
output "manually_provisioned_internal_users" {
  value = local.yaml_manually_provisioned_internal_users
}
output "list_manually_provisioned_internal_users_with_custom_security_attributes" {
  value = local.list_manually_provisioned_internal_users_with_custom_security_attributes
}
