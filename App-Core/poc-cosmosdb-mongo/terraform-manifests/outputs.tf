################################################################################################################################
# Create Outputs
# https://www.terraform.io/language/values/outputs
# https://jeffbrown.tech/terraform-module-output/
# https://stackoverflow.com/questions/64828445/can-i-automatically-see-all-child-modules-output-variables-without-re-defining
# https://stackoverflow.com/questions/70607001/module-db-is-a-list-of-object-known-only-after-apply
# https://www.reddit.com/r/Terraform/comments/pbx04m/conditional_expression_with_dependency/
# https://www.terraform.io/language/meta-arguments/count
# https://stackoverflow.com/questions/73461915/use-terraform-module-output-with-other-child-module-when-output-is-tuple
#
# Terraform Feature Flags:
# But wait, outputs are different!! https://dev.to/circa10a/how-to-use-feature-toggles-with-terraform-28fi
################################################################################################################################


####################################
# Regions Deployed
####################################
output "deploy_Europe" {
  value = local.deploy_Europe
}
output "deploy_United_States" {
  value = local.deploy_United_States
}

####################################
# Resource Group
####################################
output "myResourceGroupEurope" {
  value = local.deploy_Europe ? module.europe.0.myResourceGroup : null
  # Feature Flag on Terraform
  # module.europe is a list due to a count, you need to reference it with module.europe.0.myResourceGroup
  depends_on = [
    # https://www.terraform.io/language/values/outputs#depends_on-explicit-output-dependencies
    # when a parent module accesses an output value exported by one of its child modules, the dependencies of that output value allow Terraform to correctly determine
    # the dependencies between resources defined in different modules.
    module.europe,
  ]
}
output "myResourceGroupUS" {
  value = local.deploy_United_States ? module.us.0.myResourceGroup : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

####################################
# data.azurerm_client_config
####################################
output "myAzureSubscriptionEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "myAzureTenantIdEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureTenantId : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscriptionUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "myAzureTenantIdUS" {
  value = local.deploy_United_States ? module.us.0.myAzureTenantId : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

####################################
# DNS
####################################
output "dns_zoneEurope" {
  value = local.deploy_Europe ? module.europe.0.dns_zone : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "dns_zoneUS" {
  value = local.deploy_United_States ? module.us.0.dns_zone : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

####################################
# data.azurerm_subscription
####################################
output "myAzureSubscription_idEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_id : null
  # Feature Flag on Terraform  #  The ID of the subscription.
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_display_nameEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_display_name : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_tenant_idEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_tenant_id : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
# output "myAzureSubscription_tagsEurope" {
#   value = local.deploy_Europe ? module.europe.0.myAzureSubscription_tags : null
#   # Feature Flag on Terraform
#   depends_on = [
#     module.europe,
#   ]
# }
output "myAzureSubscription_stateEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_state : null
  # Feature Flag on Terraform  # The subscription state. Possible values are Enabled, Warned, PastDue, Disabled, and Deleted.
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_location_placement_idEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_location_placement_id : null
  # Feature Flag on Terraform # The subscription location placement ID.
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_quota_idEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_quota_id : null
  # Feature Flag on Terraform # The subscription quota ID.
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_spending_limitEurope" {
  value = local.deploy_Europe ? module.europe.0.myAzureSubscription_spending_limit : null
  # Feature Flag on Terraform # The subscription spending limit.
  depends_on = [
    module.europe,
  ]
}
output "myAzureSubscription_idUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_id : null
  # Feature Flag on Terraform  #  The ID of the subscription.
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_display_nameUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_display_name : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_tenant_idUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_tenant_id : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_tagsUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_tags : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_stateUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_state : null
  # Feature Flag on Terraform  # The subscription state. Possible values are Enabled, Warned, PastDue, Disabled, and Deleted.
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_location_placement_idUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_location_placement_id : null
  # Feature Flag on Terraform # The subscription location placement ID.
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_quota_idUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_quota_id : null
  # Feature Flag on Terraform # The subscription quota ID.
  depends_on = [
    module.us,
  ]
}
output "myAzureSubscription_spending_limitUS" {
  value = local.deploy_United_States ? module.us.0.myAzureSubscription_spending_limit : null
  # Feature Flag on Terraform # The subscription spending limit.
  depends_on = [
    module.us,
  ]
}

####################################
# Enterprise
####################################
output "enterprise_productEurope" {
  value = local.deploy_Europe ? module.europe.0.enterprise_product : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "enterprise_productUS" {
  value = local.deploy_United_States ? module.us.0.enterprise_product : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
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
output "id_linux_webapp_appcore_front_spaEurope" {
  value = local.deploy_Europe ? module.europe.0.id_linux_webapp_appcore_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "application_id_appcore_front_spaEurope" {
  value = local.deploy_Europe ? module.europe.0.application_id_appcore_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "id_linux_webapp_appcore_back_apiEurope" {
  value = local.deploy_Europe ? module.europe.0.id_linux_webapp_appcore_back_api : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "id_linux_webapp_appclink_cloud_apiEurope" {
  value = local.deploy_Europe ? module.europe.0.id_linux_webapp_appclink_cloud_api : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "id_linux_webapp_appcanalysis_pdf_rendererEurope" {
  value = local.deploy_Europe ? module.europe.0.id_linux_webapp_appcanalysis_pdf_renderer : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "id_linux_webapp_appcanalysis_viewer_front_spaEurope" {
  value = local.deploy_Europe ? module.europe.0.id_linux_webapp_appcanalysis_viewer_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "id_linux_webapp_appcore_front_spaUS" {
  value = local.deploy_United_States ? module.us.0.id_linux_webapp_appcore_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "application_id_appcore_front_spaUS" {
  value = local.deploy_United_States ? module.us.0.application_id_appcore_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "id_linux_webapp_appcore_back_apiUS" {
  value = local.deploy_United_States ? module.us.0.id_linux_webapp_appcore_back_api : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "id_linux_webapp_appclink_cloud_apiUS" {
  value = local.deploy_United_States ? module.us.0.id_linux_webapp_appclink_cloud_api : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "id_linux_webapp_appcanalysis_pdf_rendererUS" {
  value = local.deploy_United_States ? module.us.0.id_linux_webapp_appcanalysis_pdf_renderer : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "id_linux_webapp_appcanalysis_viewer_front_spaUS" {
  value = local.deploy_United_States ? module.us.0.id_linux_webapp_appcanalysis_viewer_front_spa : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

###################
## Key Vault
###################
output "appcore_keyvault_agwEurope" {
  value = local.deploy_Europe ? module.europe.0.appcore_keyvault_agw : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "keyvault_cert_secret_identifierEurope" {
  value = local.deploy_Europe ? module.europe.0.keyvault_cert_secret_identifier : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "appcore_keyvault_agwUS" {
  value = local.deploy_United_States ? module.us.0.appcore_keyvault_agw : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "keyvault_cert_secret_identifierUS" {
  value = local.deploy_United_States ? module.us.0.keyvault_cert_secret_identifier : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

##################
# App Gateway
##################

# Managed Identity
# output "myManagedIdentityEurope" {
#   value = local.deploy_Europe ? module.europe.0.myManagedIdentity : null
#     # Feature Flag on Terraform
#   depends_on = [
#     module.europe,
#   ]
# }

# output "myManagedIdentityUS" {
#   value = local.deploy_United_States ? module.us.0.myManagedIdentity : null
#     # Feature Flag on Terraform
#   depends_on = [
#     module.us,
#   ]
# }

##################
## Certificate
##################
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate
output "myCertificateNameEurope" {
  value = local.deploy_Europe ? module.europe.0.myCertificateName : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "certificate_thumbprintEurope" {
  value = local.deploy_Europe ? module.europe.0.certificate_thumbprint : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "list_of_viewersEurope" {
  value = local.deploy_Europe ? module.europe.0.list_of_viewers : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "list_of_client_login_pagesEurope" {
  value = local.deploy_Europe ? module.europe.0.list_of_client_login_pages : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}

output "login_pageEurope" {
  value = local.deploy_Europe ? module.europe.0.login_page : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}

output "myCertificateNameUS" {
  value = local.deploy_United_States ? module.us.0.myCertificateName : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "certificate_thumbprintUS" {
  value = local.deploy_United_States ? module.us.0.certificate_thumbprint : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "list_of_viewersUS" {
  value = local.deploy_United_States ? module.us.0.list_of_viewers : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "list_of_client_login_pagesUS" {
  value = local.deploy_United_States ? module.us.0.list_of_client_login_pages : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
output "login_pageUS" {
  value = local.deploy_United_States ? module.us.0.login_page : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

#####################
# Azure Portal URLs
#####################
output "azure_portal_url_with_resource_groupEurope" {
  value = local.deploy_Europe ? module.europe.0.azure_portal_url_with_resource_group : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}

# output "azure_portal_url_with_dns_zoneEurope" {
#   value = local.deploy_Europe ? module.europe.0.azure_portal_url_with_dns_zone : null
#      # Feature Flag on Terraform
#   depends_on = [
#     module.europe,
#   ]
# }

output "azure_portal_url_with_resource_groupUS" {
  value = local.deploy_United_States ? module.us.0.azure_portal_url_with_resource_group : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}
# output "azure_portal_url_with_dns_zoneUS" {
#   value = local.deploy_United_States ? module.us.0.azure_portal_url_with_dns_zone : null
#     # Feature Flag on Terraform
#   depends_on = [
#     module.us,
#   ]
# }
output "test_user1_credentialsEurope" {
  value = local.deploy_Europe ? module.europe.0.test_user1_credentials : null
  # Feature Flag on Terraform
  sensitive = true
  depends_on = [
    module.europe,
  ]
}
output "test_admin_credentialsEurope" {
  value = local.deploy_Europe ? module.europe.0.test_admin_credentials : null
  # Feature Flag on Terraform
  sensitive = true
  depends_on = [
    module.europe,
  ]
}
output "list_of_test_usersEurope" {
  value = local.deploy_Europe ? module.europe.0.list_of_test_users : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "test_user1_credentialsUS" {
  value = local.deploy_United_States ? module.us.0.test_user1_credentials : null
  # Feature Flag on Terraform
  sensitive = true
  depends_on = [
    module.us,
  ]
}
output "test_admin_credentialsUS" {
  value = local.deploy_United_States ? module.us.0.test_admin_credentials : null
  # Feature Flag on Terraform
  sensitive = true
  depends_on = [
    module.us,
  ]
}
output "list_of_test_usersUS" {
  value = local.deploy_United_States ? module.us.0.list_of_test_users : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}


#############################
# List of Clients (AETitle)
#############################
output "list_of_client_namesEurope" {
  value = local.deploy_Europe ? module.europe.0.list_of_client_names : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "list_of_client_namesUS" {
  value = local.deploy_United_States ? module.us.0.list_of_client_names : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}

#############################
# gitbranch
#############################
output "gitbranchEurope" {
  value = local.deploy_Europe ? module.europe.0.gitbranch : null
  # Feature Flag on Terraform
  depends_on = [
    module.europe,
  ]
}
output "gitbranchUS" {
  value = local.deploy_United_States ? module.us.0.gitbranch : null
  # Feature Flag on Terraform
  depends_on = [
    module.us,
  ]
}


###############################################################
# LOG ANALYTICS WORKSPACE
###############################################################
output "list_log_analytics_workspace_idEurope" {
  value = local.deploy_Europe ? module.europe.0.list_log_analytics_workspace_id : null
  depends_on = [
    module.europe,
  ]
}

output "list_log_analytics_workspace_idUS" {
  value = local.deploy_United_States ? module.us.0.list_log_analytics_workspace_id : null
  depends_on = [
    module.us,
  ]
}

output "map_list_log_analytics_workspacesEurope" {
  value = local.deploy_Europe ? module.europe.0.map_list_log_analytics_workspaces : null
  depends_on = [
    module.europe,
  ]
}

output "map_list_log_analytics_workspacesUS" {
  value = local.deploy_United_States ? module.us.0.map_list_log_analytics_workspaces : null
  depends_on = [
    module.us,
  ]
}