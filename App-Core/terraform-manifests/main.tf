# Terraform - Deploy to Multiple Regions Using Providers https://www.youtube.com/watch?v=9f-NrYZ5tQg

# Terraform Modules - The Root Module and Child Modules:
# https://www.terraform.io/language/modules
# https://www.terraform.io/language/modules/syntax
# https://jeffbrown.tech/terraform-module-output/

# Feature Flags on Terraform
# Deploy conditionally based on Feature Flag variable - https://build5nines.com/terraform-if-else-conditional-resource-and-module-deployment/
# https://build5nines.com/terraform-feature-flags-environment-toggle-design-patterns/
# But wait, outputs are different!! https://dev.to/circa10a/how-to-use-feature-toggles-with-terraform-28fi
#     https://github.com/circa10a/terraform-feature-toggle-example


# module "dns_top_level_domain" {
#   source = "./modules/dns_top_level_domain_module"
#   providers = {
#     azurerm      = azurerm.manualinfra
#   }
#   dns_zone_name_servers                                                           = module.europe.0.dns_zone_name_servers
#   environment                                                                     = var.environment
#   Enterprise_product                                                                  = var.Enterprise_product
#   gitbranch                                                                       = var.gitbranch
#   dns_parent_zone                                                                 = var.dns_parent_zone
#   dns_child_zone                                                                  = var.dns_child_zone
#   depends_on = [
#     module.europe,
#   ]
# }

data "azuread_service_principal" "aks_aad_server" {
  display_name = "Azure Kubernetes Service AAD Server"
}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

module "europe" {
  source = "./modules/appcore_module"
  count  = local.deploy_Europe ? 1 : 0
  # Feature Flag on Terraform
  # If 'true', provision 1 of this resource
  # If 'false', don't provision this
  providers = {
    azurerm      = azurerm.europe
    mongodbatlas = mongodbatlas.europe
    kubernetes   = kubernetes.europe
  }
  # Defined in variables.tf :
  # vpc_cidr                                                                       = "10.1.0.0/16" # example
  location      = var.location_europe      # "northeurope"
  location_code = var.location_code_europe # ne
  #azure_subscription                                                              = var.azure_subscription_europe
  mongodb_atlas_region                     = var.mongodb_atlas_europe_region # "EUROPE_NORTH"
  client_names                             = var.client_names_europe
  secret_appGatewayListenerSecure          = var.secret_appGatewayListenerSecure
  secret_docker_registry_server_password   = var.secret_docker_registry_server_password
  secret_mongodb_atlas_public_key          = var.secret_mongodb_atlas_public_key
  secret_mongodb_atlas_private_key         = var.secret_mongodb_atlas_private_key
  secret_mongodb_atlas_dbadmin_password    = var.secret_mongodb_atlas_dbadmin_password
  secret_mongodb_atlas_dbuser_password     = var.secret_mongodb_atlas_dbuser_password
  secret_applink_azure_devops_endpoint_pat = var.secret_applink_azure_devops_endpoint_pat
  #secret_certificate_passphrase                                                   = var.secret_certificate_passphrase
  rg_prefix                                                                                      = var.rg_prefix
  environment                                                                                    = var.environment
  gitbranch                                                                                      = var.gitbranch
  aad_tenant_id                                                                                  = var.aad_tenant_id
  vnet_cidr                                                                                      = var.vnet_cidr
  subnet_cidr                                                                                    = var.subnet_cidr
  dns_parent_zone                                                                                = var.dns_parent_zone
  dns_child_zone                                                                                 = var.dns_child_zone
  dns_prefix                                                                                     = var.dns_prefix
  dns_prefix_viewer                                                                              = var.dns_prefix_viewer
  dns_location_code                                                                              = var.dns_location_code_europe
  Enterprise_product                                                                             = var.Enterprise_product
  Enterprise_product_k8s_prefix                                                                  = var.Enterprise_product_k8s_prefix
  app-analysis-service_name                                                                      = var.app-analysis-service_name
  app_link_cloud_name                                                                            = var.app_link_cloud_name
  sp_app_link_object_id                                                                          = var.sp_app_link_object_id
  storage_prefix                                                                                 = var.storage_prefix
  storage_account_tier                                                                           = var.storage_account_tier
  storage_account_replication_type                                                               = var.storage_account_replication_type
  frontend_ip_configuration_name                                                                 = var.frontend_ip_configuration_name
  gateway_ip_configuration_name                                                                  = var.gateway_ip_configuration_name
  plan_sku                                                                                       = var.plan_sku
  docker_enable_ci                                                                               = var.docker_enable_ci
  testuser1                                                                                      = var.testuser1
  testadmin                                                                                      = var.testadmin
  oplog_size_mb                                                                                  = var.oplog_size_mb
  mongodb_atlas_org_id                                                                           = var.mongodb_atlas_org_id
  mongodb_atlas_cloud_provider                                                                   = var.mongodb_atlas_cloud_provider
  mongodb_atlas_mongodbversion                                                                   = var.mongodb_atlas_mongodbversion
  mongodb_atlas_dbadmin                                                                          = var.mongodb_atlas_dbadmin
  mongodb_atlas_dbuser                                                                           = var.mongodb_atlas_dbuser
  mongodb_atlas_database_name                                                                    = var.mongodb_atlas_database_name
  mongodb_atlas_cidr_block                                                                       = var.mongodb_atlas_cidr_block
  applink_onprem_azure_devops_pipeline_endpoint                                                  = var.applink_onprem_azure_devops_pipeline_endpoint
  docker_registry                                                                                = var.docker_registry
  docker_registry_username                                                                       = var.docker_registry_username
  app_docker_image_appcore_front_spa                                                             = var.app_docker_image_appcore_front_spa
  app_docker_image_tag_appcore_front_spa                                                         = var.app_docker_image_tag_appcore_front_spa
  app_docker_image_appcore_back_api                                                              = var.app_docker_image_appcore_back_api
  app_docker_image_tag_appcore_back_api                                                          = var.app_docker_image_tag_appcore_back_api
  app_docker_image_applink_cloud_api                                                             = var.app_docker_image_applink_cloud_api
  app_docker_image_tag_applink_cloud_api                                                         = var.app_docker_image_tag_applink_cloud_api
  app_docker_image_pdf_renderer                                                                  = var.app_docker_image_pdf_renderer
  app_docker_image_tag_pdf_renderer                                                              = var.app_docker_image_tag_pdf_renderer
  app_docker_image_analysis_viewer_frontend                                                      = var.app_docker_image_analysis_viewer_frontend
  app_docker_image_tag_analysis_viewer_frontend                                                  = var.app_docker_image_tag_analysis_viewer_frontend
  secret_applink_cloud_email_apikey                                                              = var.secret_applink_cloud_email_apikey
  app_docker_image_analysis_viewer_backend                                                       = var.app_docker_image_analysis_viewer_backend
  app_docker_image_tag_analysis_viewer_backend                                                   = var.app_docker_image_tag_analysis_viewer_backend
  aks_computation_azure_subscription_id                                                          = var.aks_computation_azure_subscription_id
  k8s_cluster_name                                                                               = var.k8s_cluster_name
  k8s_resource_group                                                                             = var.k8s_resource_group
  k8s_namespace                                                                                  = var.k8s_namespace
  vault_rbac_aad_developers_group_permissions                                                    = var.vault_rbac_aad_developers_group_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions          = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions       = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions  = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions         = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions      = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions
  vault_access_policy_aad_developers_group_key_permissions                                       = var.vault_access_policy_aad_developers_group_key_permissions
  vault_access_policy_aad_developers_group_secret_permissions                                    = var.vault_access_policy_aad_developers_group_secret_permissions
  vault_access_policy_aad_developers_group_certificate_permissions                               = var.vault_access_policy_aad_developers_group_certificate_permissions
  aad_developers_group                                                                           = var.aad_developers_group
  aad_developers_group_assigned_role                                                             = var.aad_developers_group_assigned_role
  aad_developers_group_storage_blob_assigned_role                                                = var.aad_developers_group_storage_blob_assigned_role
  aad_administrators_group                                                                       = var.aad_administrators_group
  backup_policy_retention_daily                                                                  = var.backup_policy_retention_daily
  backup_policy_retention_weekly                                                                 = var.backup_policy_retention_weekly
  backup_policy_retention_monthly                                                                = var.backup_policy_retention_monthly
  #backup_policy_retention_yearly                                                  = var.backup_policy_retention_yearly
}

module "us" {
  source = "./modules/appcore_module"
  count  = local.deploy_United_States ? 1 : 0
  # Feature Flag on Terraform
  # If 'true', provision 1 of this resource
  # If 'false', don't provision this
  providers = {
    azurerm      = azurerm.us
    mongodbatlas = mongodbatlas.us
    kubernetes   = kubernetes.us
  }
  # Defined in variables.tf :
  # vpc_cidr                                                                       = "10.1.0.0/16" # example
  location      = var.location_unitedstates      # centralus
  location_code = var.location_code_unitedstates # cus
  #azure_subscription                                                              = var.azure_subscription_unitedstates
  mongodb_atlas_region                     = var.mongodb_atlas_unitedstates_region #"US_CENTRAL" # centralus Azure Region
  client_names                             = var.client_names_unitedstates
  secret_appGatewayListenerSecure          = var.secret_appGatewayListenerSecure
  secret_docker_registry_server_password   = var.secret_docker_registry_server_password
  secret_mongodb_atlas_public_key          = var.secret_mongodb_atlas_public_key
  secret_mongodb_atlas_private_key         = var.secret_mongodb_atlas_private_key
  secret_mongodb_atlas_dbadmin_password    = var.secret_mongodb_atlas_dbadmin_password
  secret_mongodb_atlas_dbuser_password     = var.secret_mongodb_atlas_dbuser_password
  secret_applink_azure_devops_endpoint_pat = var.secret_applink_azure_devops_endpoint_pat
  #secret_certificate_passphrase                                                   = var.secret_certificate_passphrase
  rg_prefix                                                                                      = var.rg_prefix
  environment                                                                                    = var.environment
  gitbranch                                                                                      = var.gitbranch
  aad_tenant_id                                                                                  = var.aad_tenant_id
  vnet_cidr                                                                                      = var.vnet_cidr
  subnet_cidr                                                                                    = var.subnet_cidr
  dns_parent_zone                                                                                = var.dns_parent_zone
  dns_child_zone                                                                                 = var.dns_child_zone
  dns_prefix                                                                                     = var.dns_prefix
  dns_prefix_viewer                                                                              = var.dns_prefix_viewer
  dns_location_code                                                                              = var.dns_location_code_unitedstates
  Enterprise_product                                                                             = var.Enterprise_product
  Enterprise_product_k8s_prefix                                                                  = var.Enterprise_product_k8s_prefix
  app-analysis-service_name                                                                      = var.app-analysis-service_name
  app_link_cloud_name                                                                            = var.app_link_cloud_name
  sp_app_link_object_id                                                                          = var.sp_app_link_object_id
  storage_prefix                                                                                 = var.storage_prefix
  storage_account_tier                                                                           = var.storage_account_tier
  storage_account_replication_type                                                               = var.storage_account_replication_type
  frontend_ip_configuration_name                                                                 = var.frontend_ip_configuration_name
  gateway_ip_configuration_name                                                                  = var.gateway_ip_configuration_name
  plan_sku                                                                                       = var.plan_sku
  docker_enable_ci                                                                               = var.docker_enable_ci
  testuser1                                                                                      = var.testuser1
  testadmin                                                                                      = var.testadmin
  oplog_size_mb                                                                                  = var.oplog_size_mb
  mongodb_atlas_org_id                                                                           = var.mongodb_atlas_org_id
  mongodb_atlas_cloud_provider                                                                   = var.mongodb_atlas_cloud_provider
  mongodb_atlas_mongodbversion                                                                   = var.mongodb_atlas_mongodbversion
  mongodb_atlas_dbadmin                                                                          = var.mongodb_atlas_dbadmin
  mongodb_atlas_dbuser                                                                           = var.mongodb_atlas_dbuser
  mongodb_atlas_database_name                                                                    = var.mongodb_atlas_database_name
  mongodb_atlas_cidr_block                                                                       = var.mongodb_atlas_cidr_block
  applink_onprem_azure_devops_pipeline_endpoint                                                  = var.applink_onprem_azure_devops_pipeline_endpoint
  docker_registry                                                                                = var.docker_registry
  docker_registry_username                                                                       = var.docker_registry_username
  app_docker_image_appcore_front_spa                                                             = var.app_docker_image_appcore_front_spa
  app_docker_image_tag_appcore_front_spa                                                         = var.app_docker_image_tag_appcore_front_spa
  app_docker_image_appcore_back_api                                                              = var.app_docker_image_appcore_back_api
  app_docker_image_tag_appcore_back_api                                                          = var.app_docker_image_tag_appcore_back_api
  app_docker_image_applink_cloud_api                                                             = var.app_docker_image_applink_cloud_api
  app_docker_image_tag_applink_cloud_api                                                         = var.app_docker_image_tag_applink_cloud_api
  app_docker_image_pdf_renderer                                                                  = var.app_docker_image_pdf_renderer
  app_docker_image_tag_pdf_renderer                                                              = var.app_docker_image_tag_pdf_renderer
  app_docker_image_analysis_viewer_frontend                                                      = var.app_docker_image_analysis_viewer_frontend
  app_docker_image_tag_analysis_viewer_frontend                                                  = var.app_docker_image_tag_analysis_viewer_frontend
  secret_applink_cloud_email_apikey                                                              = var.secret_applink_cloud_email_apikey
  app_docker_image_analysis_viewer_backend                                                       = var.app_docker_image_analysis_viewer_backend
  app_docker_image_tag_analysis_viewer_backend                                                   = var.app_docker_image_tag_analysis_viewer_backend
  aks_computation_azure_subscription_id                                                          = var.aks_computation_azure_subscription_id
  k8s_cluster_name                                                                               = var.k8s_cluster_name
  k8s_resource_group                                                                             = var.k8s_resource_group
  k8s_namespace                                                                                  = var.k8s_namespace
  vault_rbac_aad_developers_group_permissions                                                    = var.vault_rbac_aad_developers_group_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions          = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_key_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions       = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_secret_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions  = var.vault_access_policy_compound_identity_appcore_back_api_app_role_admin_certificate_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions         = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_key_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions      = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_secret_permissions
  vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions = var.vault_access_policy_compound_identity_appcore_back_api_app_role_viewer_certificate_permissions
  vault_access_policy_aad_developers_group_key_permissions                                       = var.vault_access_policy_aad_developers_group_key_permissions
  vault_access_policy_aad_developers_group_secret_permissions                                    = var.vault_access_policy_aad_developers_group_secret_permissions
  vault_access_policy_aad_developers_group_certificate_permissions                               = var.vault_access_policy_aad_developers_group_certificate_permissions
  aad_developers_group                                                                           = var.aad_developers_group
  aad_developers_group_assigned_role                                                             = var.aad_developers_group_assigned_role
  aad_developers_group_storage_blob_assigned_role                                                = var.aad_developers_group_storage_blob_assigned_role
  aad_administrators_group                                                                       = var.aad_administrators_group
  backup_policy_retention_daily                                                                  = var.backup_policy_retention_daily
  backup_policy_retention_weekly                                                                 = var.backup_policy_retention_weekly
  backup_policy_retention_monthly                                                                = var.backup_policy_retention_monthly
  #backup_policy_retention_yearly                                                  = var.backup_policy_retention_yearly
}
