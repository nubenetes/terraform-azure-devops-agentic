####################################################################################################################################################################
# Create Outputs
#
# https://spacelift.io/blog/terraform-output
# "terraform ouput -json": This is quite useful when we want to pass the outputs to other tools for automation since JSON is way easier to handle programmatically.
# Note that Terraform does not protect sensitive output values when using the -json flag.
####################################################################################################################################################################

####################################
# Resource Group
####################################
output "myResourceGroup" {
  value = local.resource_group_name
}

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
# DNS
####################################
output "dns_zone" {
  value = local.dns_zone
}

####################################
# data.azurerm_subscription
####################################
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

####################################
# Enterprise
####################################
output "Enterprise_product" {
  value = var.Enterprise_product
}

#################
# Azure AD
#################
# output "azure_ad_application_key_id" {
#   value = azuread_application_password.web_app_resource_provider.key_id
# }
# output "azure_ad_application_password" {
#   value = azuread_application_password.web_app_resource_provider.value
#   sensitive = true
# }

#################
# App Service
#################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/linux_web_app
output "id_linux_webapp_appcore_front_spa" {
  value = data.azurerm_linux_web_app.appcore_front_spa.id
}
output "application_id_appcore_front_spa" {
  value = data.azuread_application.appcore_front_spa.application_id
}
output "id_linux_webapp_appcore_back_api" {
  value = data.azurerm_linux_web_app.appcore_back_api.id
}

output "id_linux_webapp_applink_cloud_api" {
  value = data.azurerm_linux_web_app.applink_cloud_api.id
}
output "id_linux_webapp_app-analysis_pdf_renderer" {
  value = data.azurerm_linux_web_app.app-analysis_pdf_renderer.id
}
output "id_linux_webapp_app-analysis_viewer_front_spa" {
  value = data.azurerm_linux_web_app.qcore_analysis_viewer_frontend.id
}

###################
## Key Vault
###################
output "appcore_keyvault_agw" {
  value = data.azurerm_key_vault.appcore_keyvault_agw.name
}
output "keyvault_cert_secret_identifier" {
  value = azurerm_key_vault_certificate.Enterprise_wildcard.secret_id
}

##################
# App Gateway
##################

# Managed Identity
# output "myManagedIdentity" {
#   value = data.azurerm_user_assigned_identity.appcore_agw.name
# }

##################
## Certificate
##################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate
output "myCertificateName" {
  value = data.azurerm_key_vault_certificate.appcore_certificate.name
}
output "certificate_thumbprint" {
  value = data.azurerm_key_vault_certificate.appcore_certificate.thumbprint
}
output "list_of_viewers" {
  value = local.list_of_viewers
}
output "list_of_client_login_pages" {
  value = local.list_of_client_login_pages
}

output "login_page" {
  value = local.login_page
}

## appcore analysis Viewer Backend
# output "app-analysis_viewer_back_api_myclient_application_id" {
#   value = data.azuread_application.app-analysis_viewer_back_api_myclient.application_id
# }


##############
# MongoDB
#############

output "mongodb_project_name" {
  #value = values(mongodbatlas_project.project)[*].name
  value = mongodbatlas_project.project.name
}
output "mongodb_project_id" {
  #value = values(mongodbatlas_project.project)[*].id
  value = mongodbatlas_project.project.id
}
output "mongodb_ipaccesslist" {
  value = mongodbatlas_project_ip_access_list.ip.ip_address
}
output "mongodbatlas_cluster_name" {
  value = mongodbatlas_advanced_cluster.cluster.name
}
output "mongodb_connection_strings" {
  value = mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv
}
output "mongodb_atlas_database_name" {
  value = var.mongodb_atlas_database_name
}
# output "mongodb_admin_user" {
#   #value    = mongodbatlas_database_user.admin.username
#   #value    = values(mongodbatlas_database_user.admin)[*].username
#   value   = var.mongodb_atlas_dbadmin
# }
# output "mongodb_user" {
#   #value  = mongodbatlas_database_user.user.username
#   #value   = values(mongodbatlas_database_user.user)[*].username
#   value   = var.mongodb_atlas_dbuser
# }

output "mongodb_portal_url_with_clusters_in_project" {
  value = local.mongodb_portal_url_with_clusters_in_project
}

#####################
# Azure Portal URLs
#####################
output "azure_portal_url_with_resource_group" {
  value = local.azure_portal_url_with_resource_group
}

# output "azure_portal_url_with_dns_zone" {
#   value   = local.azure_portal_url_with_dns_zone
# }

#####################
# Test Users
#####################

# output "testuser1" {
#   value     = values(azuread_user.testuser1)[*].user_principal_name
#   sensitive = true
# }
# output "testadmin" {
#   value     = values(azuread_user.testadmin)[*].user_principal_name
#   sensitive = true
# }
output "testuser1_credentials" {
  value = jsondecode(jsonencode(tomap(merge(
    { for e in var.client_names : azuread_user.testuser1["${e}"].user_principal_name => azuread_user.testuser1["${e}"].password }
  ))))
  sensitive = true
}
output "testadmin_credentials" {
  value = jsondecode(jsonencode(tomap(merge(
    { for e in var.client_names : azuread_user.testadmin["${e}"].user_principal_name => azuread_user.testadmin["${e}"].password }
  ))))
  sensitive = true
}
output "list_of_test_users" {
  # required by 01-assign-customSecurityAttributes.ps1
  value = local.list_of_test_users
}

#############################
# List of Clients (AETitle)
#############################
output "list_of_client_names" {
  value = local.list_of_client_names
}

#############################
# gitbranch
#############################
output "gitbranch" {
  value = local.gitbranch
}


###############################################################
# LOG ANALYTICS WORKSPACE
###############################################################
# output "list_log_analytics_workspace_id" {
#   value = jsondecode(jsonencode(values(azurerm_log_analytics_workspace.appcore_myclient)[*].workspace_id))
# }

# output "map_list_log_analytics_workspaces" {
#   value = jsondecode(jsonencode(local.map_list_log_analytics_workspaces))
# }
