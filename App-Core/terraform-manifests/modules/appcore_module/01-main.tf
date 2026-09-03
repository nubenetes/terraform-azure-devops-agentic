###############################################################
# AzureRM
# https://github.com/hashicorp/terraform-provider-azurerm
###############################################################
data "azurerm_subscription" "current" {
  #subscription_id   = var.azure_subscription
}
data "azurerm_resource_group" "appcore_rg" {
  name = azurerm_resource_group.appcore_rg.name
}
data "azurerm_client_config" "current" {
  #subscription_id   = azurerm_client_config.current.subscription_id
  #tenant_id         = azurerm_client_config.current.tenant_id
}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

###########################
# APP SERVICES
###########################
data "azurerm_linux_web_app" "appcore_back_api" {
  name                = azurerm_linux_web_app.appcore_back_api.name
  resource_group_name = azurerm_linux_web_app.appcore_back_api.resource_group_name
}

data "azurerm_linux_web_app" "appcore_front_spa" {
  name                = azurerm_linux_web_app.appcore_front_spa.name
  resource_group_name = azurerm_linux_web_app.appcore_front_spa.resource_group_name
}

data "azurerm_linux_web_app" "applink_cloud_api" {
  name                = azurerm_linux_web_app.applink_cloud_api.name
  resource_group_name = azurerm_linux_web_app.applink_cloud_api.resource_group_name
}

data "azurerm_linux_web_app" "app-analysis_pdf_renderer" {
  name                = azurerm_linux_web_app.app-analysis_pdf_renderer.name
  resource_group_name = azurerm_linux_web_app.app-analysis_pdf_renderer.resource_group_name
}

data "azurerm_linux_web_app" "qcore_analysis_viewer_frontend" {
  name                = azurerm_linux_web_app.app-analysis_viewer_front_spa.name
  resource_group_name = azurerm_linux_web_app.app-analysis_viewer_front_spa.resource_group_name
}

## Key Vault
data "azurerm_key_vault" "appcore_keyvault_agw" {
  name                = azurerm_key_vault.appcore_keyvault_agw.name
  resource_group_name = azurerm_key_vault.appcore_keyvault_agw.resource_group_name
}

## Certificate
data "azurerm_key_vault_certificate" "appcore_certificate" {
  name         = azurerm_key_vault_certificate.Enterprise_wildcard.name
  key_vault_id = data.azurerm_key_vault.appcore_keyvault_agw.id
}

## Managed Identity
# data "azurerm_user_assigned_identity" "appcore_agw" {
#   name                = azurerm_user_assigned_identity.appcore_agw.name
#   resource_group_name = azurerm_user_assigned_identity.appcore_agw.resource_group_name
#   #resource_group_name = azurerm_resource_group.appcore_rg.name
# }

##################################################################################################################
# Data Source: terraform-provider-azuread
# https://github.com/hashicorp/terraform-provider-azuread/tree/main/docs/data-sources
##################################################################################################################

##################################################################################################################
# Data Source: azuread_service_principal
# https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/service_principal.md
##################################################################################################################
## Web App SP:
data "azuread_service_principal" "appcore_front_spa" {
  application_id = azuread_service_principal.appcore_front_spa.application_id
}

data "azuread_service_principal" "appcore_back_api" {
  application_id = azuread_service_principal.appcore_back_api.application_id
}

##################################
# MongoDB Atlas
##################################
#data "mongodbatlas_project" "project" {
# data "mongodbatlas_project" "project" {
#   #project_id = contains(mongodbatlas_project.project, "id") ?  mongodbatlas_project.project.id : null # I'm checking if the mongodbatlas_project.project resource contains an "id" attribute.
#   #project_id = mongodbatlas_project.project.id :
#   project_id = "${mongodbatlas_project.project.id}"
# }

###########################
# Randon UUID
# The following example shows how to generate a unique name for an Azure Resource Group.
###########################
resource "random_uuid" "appcore_back_api_user_scope_id" {}
resource "random_uuid" "appcore_back_api_admin_scope_id" {}
resource "random_uuid" "applink_cloud_api_user_scope_id" {}
# resource "random_uuid" "applink_cloud_api_admin_scope_id" {}
#resource "random_uuid" "applink_cloud_api_azurekeyvault_role_id" {}
resource "random_uuid" "app-analysis_viewer_back_api_myclient_scope_id" {}
resource "random_uuid" "appcore_back_api_admin_role_id" {}
resource "random_uuid" "appcore_back_api_user_role_id" {}
resource "random_uuid" "appcore_back_api_identifier_uri" {}


resource "random_password" "testuser1" {
  for_each    = toset(var.client_names)
  length      = 10
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = false
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "random_password" "testadmin" {
  for_each    = toset(var.client_names)
  length      = 14
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  special     = false
  #special          = true  # (Boolean) Include special characters in the result. These are !@#$%&*()-_=+[]{}<>:?. Default value is true.
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

##########################################
# azuread_application_published_app_ids
##########################################
// Look up an app ID for a resource/service
// https://github.com/hashicorp/terraform-provider-azuread/issues/250
//
// https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/data-sources/application_published_app_ids.md
//    This data source uses an unofficial source of application IDs, as there is currently no available official indexed source for applications or APIs published by Microsoft:
//    https://github.com/manicminer/hamilton/blob/main/environments/published.go

// https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/resources/service_principal.md

data "azuread_application_published_app_ids" "well_known" {}

##########################################
# azuread_application
##########################################
data "azuread_application" "appcore_front_spa" {
  display_name = azuread_application.appcore_front_spa.display_name
}

##########################################
# Angular Config Json Files
# https://stackoverflow.com/questions/69219699/add-data-to-a-json-file-in-terraform
# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
# https://www.terraform.io/language/functions/templatefile
##########################################
data "template_file" "template_appcore_front_angular_settings" {
  template = templatefile("template-appcore-front-angular-settings.json", {
    clientId     = azuread_application.appcore_front_spa.application_id
    beScope      = "${local.appr_name_appcore_back_api}"
    applinkScope = "${local.appr_name_applink_cloud_api}"
  })
}
# data "template_file" "template_app-analysis_front_angular_settings" {
#   for_each    = toset(var.client_names)
#   template = templatefile("template-app-analysis-front-angular-settings-${each.value}.json", {
#     clientId  = azuread_application.app-analysis_viewer_front_spa.application_id
#     beScope   = "appr-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${each.value}-${local.instance_environment}"
#     applinkScope = "${local.appr_name_applink_cloud_api}"
#   })
# }
# Invalid value for "path" parameter: no file exists at "template-app-analysis-front-angular-settings-client-anon.json"; this function works only with files that are distributed as part
# of the configuration source code, so if this file will be created by a resource in this configuration you must instead obtain this result from an attribute of that resource.

##########################################
# Storage Account Blob Container
##########################################
data "azurerm_storage_account_blob_container_sas" "appcore" {
  connection_string = azurerm_storage_account.appcore.primary_connection_string
  container_name    = azurerm_storage_container.appcore.name
  https_only        = true
  #ip_address = "127.0.0.1"
  start  = formatdate("YYYY-MM-DD", timestamp()) #"2018-03-21"
  expiry = formatdate("YYYY-MM-DD", timestamp()) #"2018-03-21"
  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = false
    list   = true
  }
  #cache_control       = "max-age=5"
  #content_disposition = "inline"
  #content_encoding    = "deflate"
  #content_language    = "en-US"
  #content_type        = "application/json"
}




###############################################################################################
# JSON file with a List of Log Analytics Workplace Id
# https://stackoverflow.com/questions/69219699/add-data-to-a-json-file-in-terraform
# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
# https://www.terraform.io/language/functions/templatefile
###############################################################################################
# data "template_file" "list_log_analytics_workplaces" {
#   template = templatefile("list-log-analytics-workplaces.json", {
#     clientId  = azuread_application.appcore_front_spa.application_id
#     beScope   = "${local.appr_name_appcore_back_api}"
#     applinkScope = "${local.appr_name_applink_cloud_api}"
#   })
# }


#############################################################################################################################################################################
# Working with Maps in Terraform Templates as Json
# https://dev.to/jmarhee/working-with-maps-in-terraform-templates-as-json-2g36
#
# In Terraform, the template_file data source is the preferred method of, for example, injecting variable data into a templated-file like a script or configuration file.
#############################################################################################################################################################################


###################################################################################
# templatefile function
# https://developer.hashicorp.com/terraform/language/functions/templatefile
###################################################################################
