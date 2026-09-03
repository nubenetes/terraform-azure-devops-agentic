# Since these variables are re-used - a locals block makes this more maintainable
# https://stackoverflow.com/questions/71610535/dynamically-create-a-list-of-objects-to-be-used-inside-a-module-in-terraform

################################################################################
# Consuming and decoding JSON in Terraform:
# https://dev.to/lucassha/consuming-and-decoding-json-in-terraform-309p
################################################################################

locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.gitbranch}${var.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch                    = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  location                     = lower("${var.location}")
  instance_environment         = "${local.gitbranch}${var.location_code}${var.environment}"
  instance_name                = "${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name          = "${var.rg_prefix}-${local.instance_name}"
  dns_zone                     = "${var.dns_child_zone}.${var.dns_parent_zone}"
  sharedinfra_environment      = (var.environment != "pro" && var.environment != "dem" && var.environment != "res") ? "eng" : "pro" # PRO & DEM (demo) & RES (RESEARCH) environments are considered PRODUCTION
  sharedinfra_environment2     = (var.gitbranch != "main") ? "deng" : "${local.sharedinfra_environment}"
  dns_zone_resource_group_name = "${var.rg_prefix}-sharedinfra-dns-${local.sharedinfra_environment2}"
  # rg-sharedinfra-dns-deng : cert widlcard *.deng.enterprise.com : Dev, QA, UAT, Pre, Pro, Dem
  # rg-sharedinfra-dns-eng : cert wildard *.eng.enterprise.com : Dev, QA, UAT, Pre
  # rg-sharedinfra-dns-pro : cert wildcard *.apps.enterprise.com : Pro, Dem
  # Dynamic Environment Generator:
  # Used by dns names attached to apps (which lack of "prod" term when running in production)
  # Used by Azure Storage Account & Azure Key Vaults due to length constraints.
  env_generator = (var.environment != "pro") ? var.environment : ""
  # App-Core DNS Name:
  appcore_dns_name             = "${var.dns_prefix}${local.gitbranch}${var.dns_location_code}${local.env_generator}"
  app-analysis_viewer_dns_name = "${var.dns_prefix_viewer}${local.gitbranch}${var.dns_location_code}${local.env_generator}"
  appcore_fqdn                 = "${local.appcore_dns_name}.${local.dns_zone}"
  # Storage Account:
  # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
  # Your storage account name must be unique within Azure. No two storage accounts can have the same name.
  storage_account_name = "${var.storage_prefix}${local.gitbranch}${var.location_code}${local.env_generator}"
  k8s_namespace_name   = "${var.Enterprise_product_k8s_prefix}${local.gitbranch}${var.location_code}${local.env_generator}" # appcore
  # Enterprise App-Core Apps Suffix Names:
  suffix_name_appcore_front_spa         = "${var.Enterprise_product}-front-${local.instance_environment}"
  suffix_name_appcore_back_api          = "${var.Enterprise_product}-back-${local.instance_environment}"
  suffix_name_applink_cloud_api         = "${var.Enterprise_product}-${var.app_link_cloud_name}-${local.instance_environment}"
  suffix_name_pdf_renderer              = "${var.Enterprise_product}-${var.app-analysis-service_name}-pdf-renderer-${local.instance_environment}"
  suffix_name_analysis_viewer_front_spa = "${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-front-${local.instance_environment}"
  # App Registration - Enterprise App-Core:
  appr_name_appcore_front_spa         = "appr-${local.suffix_name_appcore_front_spa}"
  appr_name_appcore_back_api          = "appr-${local.suffix_name_appcore_back_api}"
  appr_name_applink_cloud_api         = "appr-${local.suffix_name_applink_cloud_api}"
  appr_name_pdf_renderer              = "appr-${local.suffix_name_pdf_renderer}"
  appr_name_analysis_viewer_front_spa = "appr-${local.suffix_name_analysis_viewer_front_spa}"
  # App Service - Enterprise App-Core:
  app_name_appcore_front_spa         = "app-${local.suffix_name_appcore_front_spa}"
  app_name_appcore_back_api          = "app-${local.suffix_name_appcore_back_api}"
  app_name_applink_cloud_api         = "app-${local.suffix_name_applink_cloud_api}"
  app_name_pdf_renderer              = "app-${local.suffix_name_pdf_renderer}"
  app_name_analysis_viewer_front_spa = "app-${local.suffix_name_analysis_viewer_front_spa}"

  ######################################################
  # List of Maps with "for" Expressions
  # https://www.terraform.io/language/expressions/for
  ######################################################
  # List of Viewers (backends, one per client)
  list_of_viewers = tolist([for e in var.client_names : "${e}-${local.app-analysis_viewer_dns_name}"])
  # List of Viewers with specific DNS name (one per client)
  list_of_viewers_redirect_uris = tolist([for e in var.client_names : "https://${e}-${local.app-analysis_viewer_dns_name}/"])
  # List of client pages (one per client)
  list_of_client_pages = tolist([for e in var.client_names : "https://${e}-${local.appcore_fqdn}/"])
  # List of client login pages (one per client)
  list_of_client_login_pages = tolist([for e in var.client_names : "https://${e}-${local.appcore_fqdn}/login"])
  # Lis of app_service_backends (one per client) - https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad
  #list_of_app-analysis_viewer_back_redirect_uris = tolist([for e in var.client_names : "https://app-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${e}-${local.gitbranch}${var.location_code}${var.environment}.azurewebsites.net/.auth/login/aad/callback"])
  list_of_test_users = [var.testuser1, var.testadmin]
  # List of Clients (AETitle)
  list_of_client_names = tolist([for e in var.client_names : e])
  # Azure Portal URLs
  # MongoDB Atlas Portal URLs
  mongodb_portal_url_with_clusters_in_project = "https://cloud.mongodb.com/v2/${mongodbatlas_project.project.id}#clusters " # Leave a whitespace before the last quotation mark to make the generated URL clickable and valid
  # AKS RBAC:
  aks_rbac_namespace_scope = "/subscriptions/${var.aks_computation_azure_subscription_id}/resourceGroups/${var.k8s_resource_group}/providers/Microsoft.ContainerService/managedClusters/${var.k8s_cluster_name}/namespaces/${var.k8s_namespace}" # Namespace Scope
  aks_rbac_cluster_scope   = "/subscriptions/${var.aks_computation_azure_subscription_id}/resourceGroups/${var.k8s_resource_group}/providers/Microsoft.ContainerService/managedClusters/${var.k8s_cluster_name}/"                                # Cluster Scope
  # App Gateway Route Table
  #agw_route_table_name                         = "rt-agw-${var.Enterprise_product}-${local.instance_environment}"
  #user_defined_route_name                      = "udr-${var.Enterprise_product}-${local.instance_environment}"

  # https://discuss.hashicorp.com/t/dynamically-generate-part-of-json/32782/2
  # map_list_log_analytics_workspaces             = tomap(merge(
  #   { for e in var.client_names : "${e}" => try(azurerm_log_analytics_workspace.appcore_myclient["${e}"].workspace_id, null) }
  #   ))
  map_list_applink_onprem_log_analytics_workspaces = tomap(merge(
    { for e in var.client_names : "${e}" => try(azurerm_log_analytics_workspace.applink_onprem_myclient["${e}"].workspace_id, null) }
  ))
  map_list_applink_onprem_app_insights_connection_strings = tomap(merge(
    { for e in var.client_names : "${e}" => try(azurerm_application_insights.applink_onprem_myclient["${e}"].connection_string, null) }
  ))
  map_list_applink_onprem_app_insights_app_ids = tomap(merge(
    { for e in var.client_names : "${e}" => try(azurerm_application_insights.applink_onprem_myclient["${e}"].app_id, null) }
  ))
  aad_group_aks_developers_name                    = "AAD_AKS_Developers_${local.gitbranch}${var.location_code}eng"
  login_page                                       = "https://${local.appcore_fqdn}/login"
  list_redirect_uris_debug_appcore_front_spa_nedev = (local.instance_environment == "nedev") ? ["http://localhost:4201/login"] : []
  # Requested by Development Team to allow local debugging when connecting their appcore frontend code running on their laptops to App-Core NEDEV running on Azure

}
