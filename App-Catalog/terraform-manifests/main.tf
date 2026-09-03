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

module "europe" {
  source = "./modules/appanalysis_module"
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
  location                               = var.location_europe      # "northeurope"
  location_code                          = var.location_code_europe # ne
  rg_prefix                              = var.rg_prefix
  environment                            = var.environment
  gitbranch                              = var.gitbranch
  aad_tenant_id                          = var.aad_tenant_id
  vnet_cidr                              = var.vnet_cidr
  subnet_cidr                            = var.subnet_cidr
  dns_parent_zone                        = var.dns_parent_zone
  dns_child_zone                         = var.dns_child_zone
  dns_prefix                             = var.dns_prefix
  dns_location_code                      = var.dns_location_code_europe
  Enterprise_product                     = var.Enterprise_product
  storage_prefix                         = var.storage_prefix
  storage_account_tier                   = var.storage_account_tier
  storage_account_replication_type       = var.storage_account_replication_type
  secret_appGatewayListenerSecure        = var.secret_appGatewayListenerSecure
  secret_docker_registry_server_password = var.secret_docker_registry_server_password
  secret_app_analysis_config_key         = var.secret_app_analysis_config_key
  backend_address_pool_name              = var.backend_address_pool_name
  frontend_port_name                     = var.frontend_port_name
  frontend_port_name_secure              = var.frontend_port_name_secure
  frontend_ip_configuration_name         = var.frontend_ip_configuration_name
  gateway_ip_configuration_name          = var.gateway_ip_configuration_name
  backend_http_settings_name             = var.backend_http_settings_name
  listener_name                          = var.listener_name
  listener_name_secure                   = var.listener_name_secure
  request_routing_rule_name              = var.request_routing_rule_name
  request_routing_rule_name_secure       = var.request_routing_rule_name_secure
  redirect_configuration_name            = var.redirect_configuration_name
  probe_name                             = var.probe_name
  cookie_name                            = var.cookie_name
  plan_sku                               = var.plan_sku
  prometheus_push_gateway                = var.prometheus_push_gateway
  docker_enable_ci                       = var.docker_enable_ci
  client_names                           = var.client_names_europe
  client_names_with_enabled_app_gateways = var.client_names_with_enabled_app_gateways_europe
  oplog_size_mb                          = var.oplog_size_mb
  secret_mongodb_atlas_public_key        = var.secret_mongodb_atlas_public_key
  secret_mongodb_atlas_private_key       = var.secret_mongodb_atlas_private_key
  mongodb_atlas_org_id                   = var.mongodb_atlas_org_id
  mongodb_atlas_cloud_provider           = var.mongodb_atlas_cloud_provider
  mongodb_atlas_region                   = var.mongodb_atlas_europe_region # "EUROPE_NORTH"
  mongodb_atlas_mongodbversion           = var.mongodb_atlas_mongodbversion
  mongodb_atlas_dbadmin                  = var.mongodb_atlas_dbadmin
  secret_mongodb_atlas_dbadmin_password  = var.secret_mongodb_atlas_dbadmin_password
  mongodb_atlas_dbuser                   = var.mongodb_atlas_dbuser
  secret_mongodb_atlas_dbuser_password   = var.secret_mongodb_atlas_dbuser_password
  mongodb_atlas_database_name            = var.mongodb_atlas_database_name
  mongodb_atlas_cidr_block               = var.mongodb_atlas_cidr_block
  docker_registry                        = var.docker_registry
  docker_registry_username               = var.docker_registry_username
  app_docker_image                       = var.app_docker_image
  app_docker_image_tag                   = var.app_docker_image_tag
  prometheus_exporter_docker_image       = var.prometheus_exporter_docker_image
  prometheus_exporter_docker_image_tag   = var.prometheus_exporter_docker_image_tag
  aks_computation_azure_subscription_id  = var.aks_computation_azure_subscription_id
  k8s_cluster_name                       = var.k8s_cluster_name
  k8s_resource_group                     = var.k8s_resource_group
  k8s_namespace                          = var.k8s_namespace
  aad_developers_group                   = var.aad_developers_group
  aad_developers_group_assigned_role     = var.aad_developers_group_assigned_role
  test_user1                             = var.test_user1
  test_admin                             = var.test_admin
}







module "us" {
  source = "./modules/appanalysis_module"
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
  location                               = var.location_unitedstates      # "centralus"
  location_code                          = var.location_code_unitedstates # cus
  rg_prefix                              = var.rg_prefix
  environment                            = var.environment
  gitbranch                              = var.gitbranch
  aad_tenant_id                          = var.aad_tenant_id
  vnet_cidr                              = var.vnet_cidr
  subnet_cidr                            = var.subnet_cidr
  dns_parent_zone                        = var.dns_parent_zone
  dns_child_zone                         = var.dns_child_zone
  dns_prefix                             = var.dns_prefix
  dns_location_code                      = var.dns_location_code_unitedstates
  Enterprise_product                     = var.Enterprise_product
  storage_prefix                         = var.storage_prefix
  storage_account_tier                   = var.storage_account_tier
  storage_account_replication_type       = var.storage_account_replication_type
  secret_appGatewayListenerSecure        = var.secret_appGatewayListenerSecure
  secret_docker_registry_server_password = var.secret_docker_registry_server_password
  secret_app_analysis_config_key         = var.secret_app_analysis_config_key
  backend_address_pool_name              = var.backend_address_pool_name
  frontend_port_name                     = var.frontend_port_name
  frontend_port_name_secure              = var.frontend_port_name_secure
  frontend_ip_configuration_name         = var.frontend_ip_configuration_name
  gateway_ip_configuration_name          = var.gateway_ip_configuration_name
  backend_http_settings_name             = var.backend_http_settings_name
  listener_name                          = var.listener_name
  listener_name_secure                   = var.listener_name_secure
  request_routing_rule_name              = var.request_routing_rule_name
  request_routing_rule_name_secure       = var.request_routing_rule_name_secure
  redirect_configuration_name            = var.redirect_configuration_name
  probe_name                             = var.probe_name
  cookie_name                            = var.cookie_name
  plan_sku                               = var.plan_sku
  prometheus_push_gateway                = var.prometheus_push_gateway
  docker_enable_ci                       = var.docker_enable_ci
  client_names                           = var.client_names_unitedstates
  client_names_with_enabled_app_gateways = var.client_names_with_enabled_app_gateways_unitedstates
  oplog_size_mb                          = var.oplog_size_mb
  secret_mongodb_atlas_public_key        = var.secret_mongodb_atlas_public_key
  secret_mongodb_atlas_private_key       = var.secret_mongodb_atlas_private_key
  mongodb_atlas_org_id                   = var.mongodb_atlas_org_id
  mongodb_atlas_cloud_provider           = var.mongodb_atlas_cloud_provider
  mongodb_atlas_region                   = var.mongodb_atlas_unitedstates_region # "US_CENTRAL"
  mongodb_atlas_mongodbversion           = var.mongodb_atlas_mongodbversion
  mongodb_atlas_dbadmin                  = var.mongodb_atlas_dbadmin
  secret_mongodb_atlas_dbadmin_password  = var.secret_mongodb_atlas_dbadmin_password
  mongodb_atlas_dbuser                   = var.mongodb_atlas_dbuser
  secret_mongodb_atlas_dbuser_password   = var.secret_mongodb_atlas_dbuser_password
  mongodb_atlas_database_name            = var.mongodb_atlas_database_name
  mongodb_atlas_cidr_block               = var.mongodb_atlas_cidr_block
  docker_registry                        = var.docker_registry
  docker_registry_username               = var.docker_registry_username
  app_docker_image                       = var.app_docker_image
  app_docker_image_tag                   = var.app_docker_image_tag
  prometheus_exporter_docker_image       = var.prometheus_exporter_docker_image
  prometheus_exporter_docker_image_tag   = var.prometheus_exporter_docker_image_tag
  aks_computation_azure_subscription_id  = var.aks_computation_azure_subscription_id
  k8s_cluster_name                       = var.k8s_cluster_name
  k8s_resource_group                     = var.k8s_resource_group
  k8s_namespace                          = var.k8s_namespace
  aad_developers_group                   = var.aad_developers_group
  aad_developers_group_assigned_role     = var.aad_developers_group_assigned_role
  test_user1                             = var.test_user1
  test_admin                             = var.test_admin
}
