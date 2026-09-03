#######################################################################################
# App Service 6: Enterprise App-Core analysis Viewer Backend - Client
#######################################################################################


#######################################################################################
# TEMPORARY WORKAROUND: app-analysis's registered app is the legacy one (manually setup)
# To be replaced in the near future by a registered app created by terraform
# To Do: app-analysis's frontend with OAUTH2
#######################################################################################
data "azuread_application" "app-analysis_viewer_spa_legacy_dev" {
  display_name = "dev-appcore-analysisFrontEndService"
}
data "azuread_application" "app-analysis_viewer_back_api_legacy_dev" {
  display_name = "dev-appcore-analysisBackEndService"
}
data "azuread_application" "app-analysis_viewer_spa_api_legacy_pro" {
  display_name = "appr-analysis-viewer-frontend"
}
data "azuread_application" "app-analysis_viewer_back_api_legacy_pro" {
  display_name = "appr-analysis-viewer-backend"
}

#######################################################################################
# Environment variables and app settings in Azure App Service
# https://learn.microsoft.com/en-us/azure/app-service/reference-app-settings
#######################################################################################

resource "azurerm_linux_web_app" "app-analysis_viewer_back_api_myclient" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "app-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "AllAllowed"
    application_stack {
      docker_image     = var.app_docker_image_analysis_viewer_backend
      docker_image_tag = var.app_docker_image_tag_analysis_viewer_backend
    }
  }

  # https://docs.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage
  # From the left navigation, click Configuration > Path Mappings > New Azure Storage Mount.
  #
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app#storage_account
  # storage_account {
  #   name         = azurerm_storage_account.appcore.name
  #   account_name = azurerm_storage_account.appcore.name #local.storage_account_name
  #   access_key   = azurerm_storage_account.appcore.primary_access_key
  #   share_name   = "fs-${var.Enterprise_product}-${each.value}-${var.environment}"
  #   type         = "AzureFiles" #"AzureBlob"
  #   #mount_path   = "/records"  #(optional)
  # }

  app_settings = {
    AE_TITLE        = "${each.value}"
    APP_ENVIRONMENT = local.appcore_dns_name
    #AZURE_CLIENT_ID                     = (var.environment != "pro") ? azuread_application.app-analysis_viewer_back_api_myclient[each.key].application_id:"00000000-0000-0000-0000-000000000000"
    #AZURE_CLIENT_SECRET                 = (var.environment != "pro") ? azuread_application_password.app-analysis_viewer_back_api_myclient[each.key].value:"00000~ANONYMIZED_SECRET_00000"
    AZURE_CLIENT_ID                 = ((var.environment != "pro") && (var.environment != "res") && (var.environment != "dem")) ? data.azuread_application.app-analysis_viewer_back_api_legacy_dev.application_id : data.azuread_application.app-analysis_viewer_back_api_legacy_pro.application_id
    AZURE_CLIENT_SECRET             = ((var.environment != "pro") && (var.environment != "res") && (var.environment != "dem")) ? "00000~ANONYMIZED_SECRET_00000" : "00000~ANONYMIZED_SECRET_00000"
    AZURE_TENANT_ID                 = var.aad_tenant_id
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    applink_URL                     = "https://${local.appcore_fqdn}/applinkcloud"
    PDF_URL                         = "https://${local.appcore_fqdn}/report/pdf"
    MONGO_URL                       = replace(join("/", [mongodbatlas_advanced_cluster.cluster.connection_strings.0.standard_srv, "modb-${var.Enterprise_product}-${each.value}"]), "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@") # Dec 21st 2022: still required by THIS app service (instead of pulling secret from KV)
    Enterprise_BASE_PATH            = "/home/workspace/compose_omni/Enterprise"
    Enterprise_record_PATH          = "/records"
    STORAGE_ACCESS_KEY              = azurerm_storage_account.appcore.primary_access_key
    STORAGE_ACCOUNT                 = azurerm_storage_account.appcore.name
    STORAGE_DISK                    = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
    WEBSITES_PORT                   = 3002 # this is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
  }
  logs {
    application_logs {
      azure_blob_storage { # Optional
        level             = "Verbose"
        retention_in_days = 0
        sas_url           = data.azurerm_storage_account_blob_container_sas.appcore.sas
      }
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      azure_blob_storage {
        retention_in_days = 0
        sas_url           = data.azurerm_storage_account_blob_container_sas.appcore.sas
      }
    }
  }
  depends_on = [
    azurerm_service_plan.appcore_service_plan,
    azurerm_storage_account.appcore,
  ]
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# primary_access_key - The primary access key for the storage account.
# secondary_access_key - The secondary access key for the storage account.
# primary_connection_string - The connection string associated with the primary location.
# secondary_connection_string - The connection string associated with the secondary location.
# primary_blob_connection_string - The connection string associated with the primary blob location.
# secondary_blob_connection_string - The connection string associated with the secondary blob location.


##################################################################################################################################################################################################################################################
# To set up a multi-tenant Azure App Service, you can follow these general steps:
#
# Configure Authentication:
# First, you need to configure the authentication for your app service. You can use Azure Active Directory (AAD) as your identity provider to authenticate users for your multi-tenant app.
# For this, you need to create an AAD tenant, configure an app registration for your multi-tenant app, and grant the necessary permissions to access your app service.
#
# Implement Authorization:
# Next, you need to implement authorization for your app service. This involves defining the access control policies for the different user roles (e.g., admins, users) in your multi-tenant app.
# You can use Azure Role-Based Access Control (RBAC) to manage these access policies.
#
# Implement Multi-Tenancy:
# Now, you need to implement the multi-tenancy feature for your app service. This involves defining the tenant boundaries for your app service, so that users from different tenants can access your app with different access rights.
# You can use Azure Active Directory's App Roles feature to define different roles for users from different tenants.
#
# Configure Storage and Data Isolation:
# You also need to configure storage and data isolation for your multi-tenant app. This involves setting up different data stores or databases for each tenant, so that the tenant data is separated and secure.
# You can use Azure SQL Database or Azure Cosmos DB for this purpose.
#
# Test and Deploy:
# Finally, you need to test and deploy your multi-tenant app to Azure App Service. You can use Azure DevOps or any other deployment tool to automate this process and ensure consistency across different environments.
#
# To summarize, setting up a multi-tenant Azure App Service involves configuring authentication, implementing authorization, implementing multi-tenancy, configuring storage and data isolation, and testing and deploying the app service.
##################################################################################################################################################################################################################################################