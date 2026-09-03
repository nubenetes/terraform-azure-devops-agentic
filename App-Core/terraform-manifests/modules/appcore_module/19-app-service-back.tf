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
# App Service 5: Enterprise App-Core PDF Renderer
# backendPool:  app-corecore-pdf-renderer-dev
#######################################################################################
resource "azurerm_linux_web_app" "app-analysis_pdf_renderer" {
  name                = local.app_name_pdf_renderer
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "Disabled"
    application_stack {
      docker_image     = var.app_docker_image_pdf_renderer
      docker_image_tag = var.app_docker_image_tag_pdf_renderer
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    WEBSITES_PORT                   = 3003 # this is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
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


