####################################
# Create Root Outputs
####################################

####################################
# Europe Region Outputs
####################################
output "europe_myResourceGroup" {
  value = local.deploy_Europe ? module.europe[0].myResourceGroup : null
}

output "europe_myAzureTenantId" {
  value = local.deploy_Europe ? module.europe[0].myAzureTenantId : null
}

output "europe_list_of_client_names" {
  value = local.deploy_Europe ? module.europe[0].list_of_client_names : null
}

output "europe_dns_zone" {
  value = local.deploy_Europe ? module.europe[0].dns_zone : null
}

output "europe_Enterprise_product" {
  value = local.deploy_Europe ? module.europe[0].Enterprise_product : null
}

output "europe_myAzureSubscription" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription : null
}

output "europe_myAzureSubscription_id" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_id : null
}

output "europe_myAzureSubscription_display_name" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_display_name : null
}

output "europe_myAzureSubscription_tenant_id" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_tenant_id : null
}

output "europe_myAzureSubscription_tags" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_tags : null
}

output "europe_myAzureSubscription_state" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_state : null
}

output "europe_myAzureSubscription_location_placement_id" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_location_placement_id : null
}

output "europe_myAzureSubscription_quota_id" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_quota_id : null
}

output "europe_myAzureSubscription_spending_limit" {
  value = local.deploy_Europe ? module.europe[0].myAzureSubscription_spending_limit : null
}

output "europe_azure_ad_application_key_id" {
  value = local.deploy_Europe ? module.europe[0].azure_ad_application_key_id : null
}

output "europe_azure_ad_application_password" {
  value     = local.deploy_Europe ? module.europe[0].azure_ad_application_password : null
  sensitive = true
}

output "europe_id_linux_webapp_App-Catalog" {
  value = local.deploy_Europe ? module.europe[0].id_linux_webapp_App-Catalog : null
}

output "europe_id_linux_webapp_monitor_client" {
  value = local.deploy_Europe ? module.europe[0].id_linux_webapp_monitor_client : null
}

output "europe_App-Catalog_keyvault" {
  value = local.deploy_Europe ? module.europe[0].App-Catalog_keyvault : null
}

output "europe_keyvault_cert_secret_identifier" {
  value = local.deploy_Europe ? module.europe[0].keyvault_cert_secret_identifier : null
}

output "europe_myAppGateway" {
  value = local.deploy_Europe ? module.europe[0].myAppGateway : null
}

output "europe_myManagedIdentity" {
  value = local.deploy_Europe ? module.europe[0].myManagedIdentity : null
}

output "europe_myCertificateName" {
  value = local.deploy_Europe ? module.europe[0].myCertificateName : null
}

output "europe_certificate_thumbprint" {
  value = local.deploy_Europe ? module.europe[0].certificate_thumbprint : null
}

output "europe_mongodb_project_name" {
  value = local.deploy_Europe ? module.europe[0].mongodb_project_name : null
}

output "europe_mongob_project_id" {
  value = local.deploy_Europe ? module.europe[0].mongob_project_id : null
}

output "europe_mongodb_project_id" {
  value = local.deploy_Europe ? module.europe[0].mongodb_project_id : null
}

output "europe_mongodb_ipaccesslist" {
  value = local.deploy_Europe ? module.europe[0].mongodb_ipaccesslist : null
}

output "europe_mongodb_connection_strings" {
  value = local.deploy_Europe ? module.europe[0].mongodb_connection_strings : null
}

output "europe_list_of_login_pages" {
  value = local.deploy_Europe ? module.europe[0].list_of_login_pages : null
}

####################################
# United States Region Outputs
####################################
output "us_myResourceGroup" {
  value = local.deploy_United_States ? module.us[0].myResourceGroup : null
}

output "us_myAzureTenantId" {
  value = local.deploy_United_States ? module.us[0].myAzureTenantId : null
}

output "us_list_of_client_names" {
  value = local.deploy_United_States ? module.us[0].list_of_client_names : null
}

output "us_dns_zone" {
  value = local.deploy_United_States ? module.us[0].dns_zone : null
}

output "us_Enterprise_product" {
  value = local.deploy_United_States ? module.us[0].Enterprise_product : null
}

output "us_myAzureSubscription" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription : null
}

output "us_myAzureSubscription_id" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_id : null
}

output "us_myAzureSubscription_display_name" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_display_name : null
}

output "us_myAzureSubscription_tenant_id" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_tenant_id : null
}

output "us_myAzureSubscription_tags" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_tags : null
}

output "us_myAzureSubscription_state" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_state : null
}

output "us_myAzureSubscription_location_placement_id" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_location_placement_id : null
}

output "us_myAzureSubscription_quota_id" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_quota_id : null
}

output "us_myAzureSubscription_spending_limit" {
  value = local.deploy_United_States ? module.us[0].myAzureSubscription_spending_limit : null
}

output "us_azure_ad_application_key_id" {
  value = local.deploy_United_States ? module.us[0].azure_ad_application_key_id : null
}

output "us_azure_ad_application_password" {
  value     = local.deploy_United_States ? module.us[0].azure_ad_application_password : null
  sensitive = true
}

output "us_id_linux_webapp_App-Catalog" {
  value = local.deploy_United_States ? module.us[0].id_linux_webapp_App-Catalog : null
}

output "us_id_linux_webapp_monitor_client" {
  value = local.deploy_United_States ? module.us[0].id_linux_webapp_monitor_client : null
}

output "us_App-Catalog_keyvault" {
  value = local.deploy_United_States ? module.us[0].App-Catalog_keyvault : null
}

output "us_keyvault_cert_secret_identifier" {
  value = local.deploy_United_States ? module.us[0].keyvault_cert_secret_identifier : null
}

output "us_myAppGateway" {
  value = local.deploy_United_States ? module.us[0].myAppGateway : null
}

output "us_myManagedIdentity" {
  value = local.deploy_United_States ? module.us[0].myManagedIdentity : null
}

output "us_myCertificateName" {
  value = local.deploy_United_States ? module.us[0].myCertificateName : null
}

output "us_certificate_thumbprint" {
  value = local.deploy_United_States ? module.us[0].certificate_thumbprint : null
}

output "us_mongodb_project_name" {
  value = local.deploy_United_States ? module.us[0].mongodb_project_name : null
}

output "us_mongob_project_id" {
  value = local.deploy_United_States ? module.us[0].mongob_project_id : null
}

output "us_mongodb_project_id" {
  value = local.deploy_United_States ? module.us[0].mongodb_project_id : null
}

output "us_mongodb_ipaccesslist" {
  value = local.deploy_United_States ? module.us[0].mongodb_ipaccesslist : null
}

output "us_mongodb_connection_strings" {
  value = local.deploy_United_States ? module.us[0].mongodb_connection_strings : null
}

output "us_list_of_login_pages" {
  value = local.deploy_United_States ? module.us[0].list_of_login_pages : null
}
