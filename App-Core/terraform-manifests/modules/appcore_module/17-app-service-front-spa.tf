# Boilerplates:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/app-service

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app

#######################################################################################
# Environment variables and app settings in Azure App Service
# https://learn.microsoft.com/en-us/azure/app-service/reference-app-settings
#######################################################################################

#######################################################################################
# App Service 1: Enterprise App-Core Portal Frontend
# backendPool:  app-corecore-frontend
#######################################################################################
resource "azurerm_linux_web_app" "appcore_front_spa" {
  name                = local.app_name_appcore_front_spa
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "Disabled"
    application_stack {
      docker_image     = var.app_docker_image_appcore_front_spa
      docker_image_tag = var.app_docker_image_tag_appcore_front_spa
    }
  }

  app_settings = {
    #AZURE_CLIENT_ID                     = azuread_application.appcore_back_api.application_id     
    #AZURE_CLIENT_SECRET                 = azuread_application_password.appcore_back_api.value    
    #AZURE_TENANT_ID                     = var.aad_tenant_id
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    #NODE_ENV                            = var.environment  # production, development, etc
    WEBSITES_PORT = 80 # this is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
  }
  #######################################################################################
  # App Service Logs
  # https://learn.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs
  #######################################################################################
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
  storage_account {
    name         = "appcore-frontend-angular-settings"
    access_key   = azurerm_storage_account.appcore.primary_access_key
    account_name = azurerm_storage_account.appcore.name
    share_name   = azurerm_storage_container.appcore.name
    type         = "AzureBlob"
    mount_path   = "/usr/share/nginx/html/env"
  }
  depends_on = [
    azurerm_service_plan.appcore_service_plan,
    azurerm_linux_web_app.appcore_back_api,
    azurerm_storage_account.appcore,
    azurerm_storage_container.appcore,
  ]
}


#######################################################################################
# App Service 2: Enterprise App-Core analysis Viewer Frontend
# backendPool:  app-viewer-frontend-dev
#######################################################################################
resource "azurerm_linux_web_app" "app-analysis_viewer_front_spa" {
  name                = local.app_name_analysis_viewer_front_spa
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "Disabled"
    application_stack {
      docker_image     = var.app_docker_image_analysis_viewer_frontend
      docker_image_tag = var.app_docker_image_tag_analysis_viewer_frontend
    }
  }

  app_settings = {
    #AZURE_CLIENT_ID                     = azuread_application.app-analysis_viewer_front_spa.application_id     
    #AZURE_CLIENT_SECRET                 = azuread_application_password.app-analysis_viewer_front_spa.value    
    #AZURE_TENANT_ID                     = var.aad_tenant_id
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    WEBSITES_PORT                   = 80
  }
  #######################################################################################
  # App Service Logs
  # https://learn.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs
  #######################################################################################
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
  storage_account {
    name         = "app-analysis-frontend-angular-settings"
    access_key   = azurerm_storage_account.appcore.primary_access_key
    account_name = azurerm_storage_account.appcore.name
    share_name   = azurerm_storage_container.appcore.name
    type         = "AzureBlob"
    mount_path   = "/usr/share/nginx/html/env"
  }
  depends_on = [
    azurerm_service_plan.appcore_service_plan,
    azurerm_linux_web_app.app-analysis_viewer_back_api_myclient,
    azurerm_storage_account.appcore,
    azurerm_storage_container.appcore,
  ]
}


