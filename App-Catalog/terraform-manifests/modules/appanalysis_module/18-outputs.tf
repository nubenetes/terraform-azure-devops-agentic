####################################
# Create Outputs
####################################

# Resource Group
output "myResourceGroup" {
  value = values(azurerm_resource_group.App-Catalog_rg)[*].name # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
}

output "myAzureTenantId" {
  value = data.azurerm_client_config.current.tenant_id
}

output "list_of_client_names" {
  value = var.client_names
}
output "dns_zone" {
  value = local.dns_zone
}
output "Enterprise_product" {
  value = var.Enterprise_product
}

####################################
# data.azurerm_subscription
####################################

# Azure Subscription
output "myAzureSubscription" {
  value = data.azurerm_client_config.current.subscription_id
}
output "myAzureSubscription_id" {
  value = data.azurerm_subscription.current.id #  The ID of the subscription.
}
output "myAzureSubscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}
output "myAzureSubscription_tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
output "myAzureSubscription_tags" {
  value = data.azurerm_subscription.current.tags
}
output "myAzureSubscription_state" {
  value = data.azurerm_subscription.current.state # The subscription state. Possible values are Enabled, Warned, PastDue, Disabled, and Deleted.
}
output "myAzureSubscription_location_placement_id" {
  value = data.azurerm_subscription.current.location_placement_id # The subscription location placement ID.
}
output "myAzureSubscription_quota_id" {
  value = data.azurerm_subscription.current.quota_id # The subscription quota ID.
}
output "myAzureSubscription_spending_limit" {
  value = data.azurerm_subscription.current.spending_limit # The subscription spending limit.
}

#################
# Azure AD
#################
output "azure_ad_application_key_id" {
  value = values(azuread_application_password.App-Catalog)[*].key_id
}
output "azure_ad_application_password" {
  value     = values(azuread_application_password.App-Catalog)[*].value
  sensitive = true
}

#################
# App Service
#################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/linux_web_app
output "id_linux_webapp_App-Catalog" {
  value = values(azurerm_linux_web_app.App-Catalog)[*].id
}
output "id_linux_webapp_monitor_client" {
  value = values(azurerm_linux_web_app.monitor_client)[*].id
}

###################
# Key Vault
###################
output "App-Catalog_keyvault" {
  value = values(azurerm_key_vault.App-Catalog_keyvault)[*].name
}
output "keyvault_cert_secret_identifier" {
  value = values(azurerm_key_vault_certificate.Enterprise_wildcard)[*].secret_id
}

##################
# App Gateway
##################
output "myAppGateway" {
  value = values(azurerm_application_gateway.App-Catalog_agw)[*].name
}
## Managed Identity
output "myManagedIdentity" {
  value = values(azurerm_user_assigned_identity.App-Catalog_agw)[*].name
}

##################
# Certificate
##################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate
output "myCertificateName" {
  value = values(azurerm_key_vault_certificate.Enterprise_wildcard)[*].name
}

output "certificate_thumbprint" {
  value = values(azurerm_key_vault_certificate.Enterprise_wildcard)[*].thumbprint
}

##############
# MongoDB
#############
output "mongodb_project_name" {
  value = values(mongodbatlas_project.project)[*].name
}
output "mongob_project_id" {
  value = values(mongodbatlas_project.project)[*].id
}
output "mongodb_ipaccesslist" {
  value = values(mongodbatlas_project_ip_access_list.ip)[*].ip_address
}
output "mongodb_connection_strings" {                                                         # type object - key:value
  value = values(mongodbatlas_advanced_cluster.cluster)[*].connection_strings[0].standard_srv # type tuple
}

# output "mongodb_admin_user" {
#   value    = values(mongodbatlas_database_user.admin)[*].username
# }
# output "mongodb_user" {
#   value    = values(mongodbatlas_database_user.user)[*].username
# }

#####################
# Login Pages
#####################
output "list_of_login_pages" {
  value = local.list_of_login_pages
}

#####################
# Test Users
#####################
# output "test_user1_credentials" {
#   value     =  [values(azuread_user.test_user1)[*].user_principal_name, values(azuread_user.test_user1)[*].password]
#   sensitive = true
# }
# output "test_admin_credentials" {
#   value     = [values(azuread_user.test_admin)[*].user_principal_name, values(azuread_user.test_admin)[*].password]
#   sensitive = true
# }
