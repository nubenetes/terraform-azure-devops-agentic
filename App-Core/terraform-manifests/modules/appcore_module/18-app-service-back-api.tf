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
# App Service 3: Enterprise App-Core Portal Backend
# backendPool:  app-corecore-Backend
#######################################################################################
resource "azurerm_linux_web_app" "appcore_back_api" {
  name                = local.app_name_appcore_back_api
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "Disabled"
    application_stack {
      docker_image     = var.app_docker_image_appcore_back_api
      docker_image_tag = var.app_docker_image_tag_appcore_back_api
    }
  }
  app_settings = {
    APP_ENVIRONMENT                 = local.appcore_dns_name # The name of corresponding key-vault-client is obtained from this: kv-<AETITLE>-<APP_ENVIRONMENT>
    AZURE_CLIENT_ID                 = azuread_application.appcore_back_api.application_id
    AZURE_CLIENT_SECRET             = azuread_application_password.appcore_back_api.value
    AZURE_TENANT_ID                 = var.aad_tenant_id
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    applink_CLIENT_ID               = local.appr_name_applink_cloud_api
    applink_DOWNLOAD_KEY            = var.secret_applink_azure_devops_endpoint_pat
    applink_DOWNLOAD_URL            = var.applink_onprem_azure_devops_pipeline_endpoint
    applink_URL                     = "https://${local.appcore_fqdn}/applinkcloud/"
    #applink_URL                            = "https://${local.app_name_applink_cloud_api}.azurewebsites.net"
    WEBSITES_CONTAINER_START_TIME_LIMIT = 1800 # Increase the container warmup request timeout. The warmup request by default fails after waiting 240 seconds for a reply from the container. You may increase the container warmup request timeout by adding the application setting WEBSITES_CONTAINER_START_TIME_LIMIT with a value between 240 and 1800 seconds.
    WEBSITES_PORT                       = 3001 # this is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
    SUPPORT_EMAIL                       = "cloud-admin@example.com"
    #LOG_ANALYTICS_WORKSPACE_ID           = jsonencode(local.map_list_log_analytics_workspaces) # because map_list_log_analytics_workspaces is of type map, it must be converted using jsonencode
    # Ref: https://dev.to/jmarhee/working-with-maps-in-terraform-templates-as-json-2g36
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.appcore_back.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = 3
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
  depends_on = [
    azurerm_service_plan.appcore_service_plan,
    azurerm_storage_account.appcore,
    #azurerm_log_analytics_workspace.appcore_myclient,
    azurerm_log_analytics_workspace.appcore_back,
  ]
}


#######################################################################################
# App Service 4: Enterprise App-Link Cloud
# backendPool:  app-corelink-cloud
#######################################################################################
resource "azurerm_linux_web_app" "applink_cloud_api" {
  name                = local.app_name_applink_cloud_api
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  service_plan_id     = azurerm_service_plan.appcore_service_plan.id
  https_only          = true
  tags                = local.tags
  site_config {
    ftps_state = "Disabled"
    application_stack {
      docker_image     = var.app_docker_image_applink_cloud_api
      docker_image_tag = var.app_docker_image_tag_applink_cloud_api
    }
  }

  # connection_string {
  #   # https://docs.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-app-settings
  #   # For ASP.NET and ASP.NET Core developers, setting connection strings in App Service are like setting them in <connectionStrings> in Web.config, but the values you set in App Service override the ones in Web.config.
  #   # You can keep development settings (for example, a database file) in Web.config and production secrets (for example, SQL Database credentials) safely in App Service. The same code uses your development settings when you debug locally,
  #   # and it uses your production secrets when deployed to Azure.
  #   # For other language stacks, it's better to use app settings instead, because connection strings require special formatting in the variable keys in order to access the values.
  #   #
  #   name  = "${var.mongodb_atlas_database_name}"
  #   type  = "DocDb"
  #   #value = mongodbatlas_cluster.cluster[each.key].connection_strings.0.standard_srv
  #   #value = replace(mongodbatlas_cluster.cluster.connection_strings.0.standard_srv, "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
  #   value = replace(join("/", [mongodbatlas_cluster.cluster.connection_strings.0.standard_srv , "modb-${var.Enterprise_product}-Enterprise"]), "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
  # }
  app_settings = {
    APP_ENVIRONMENT                    = local.appcore_dns_name
    AZURE_CLIENT_ID                    = azuread_application.applink_cloud_api.application_id
    AZURE_CLIENT_SECRET                = azuread_application_password.applink_cloud_api.value
    AZURE_DIRECTORY_ID                 = var.aad_tenant_id
    DCM_VALIDATOR_PATH                 = "/usr/bin"
    DOCKER_ENABLE_CI                   = var.docker_enable_ci
    DOCKER_REGISTRY_SERVER_PASSWORD    = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL         = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME    = var.docker_registry_username
    ENV_PIPELINE_RETURN_URL            = "https://${local.appcore_fqdn}/applinkcloud/pipeline/execution/{center}/{pipelineExecutionId}"
    ENV_PVB_RETURN_URL                 = "https://${local.appcore_fqdn}/applinkcloud/pipeline/execution/{center}/{pipelineExecutionId}"
    K8_CLUSTER_NAME                    = var.k8s_cluster_name
    K8_RESOURCE_GROUP                  = var.k8s_resource_group
    K8_SUBSCRIPTION_ID                 = var.aks_computation_azure_subscription_id
    WEBSITE_HTTPLOGGING_RETENTION_DAYS = 5
    WEBSITES_PORT                      = 9201 # this is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
    # TROUBLESHOOTING SETTINGS:
    # WEBSITE_HTTPLOGGING_CONTAINER_URL   = "?sv=2000-01-01&sr=c&st=2000-01-01&se=2000-01-01&sp=racwl&spr=https&sig=33xSIEP1AhFQXVFdn2FHs08bfHDT%2B68hll1Iognu1AU%3D"
    # A hidden app setting which is used to store the web server log's blob container url
    # After you have enabled the web server logging in the diagnostics logs, it will add your storage container url in the app setting. You couldn't change it in the application settings.
    # https://stackoverflow.com/questions/44136929/website-httplogging-container-url-is-a-hidden-application-setting
    # DIAGNOSTICS_AZUREBLOBRETENTIONINDAYS = 0
    # DIAGNOSTICS_AZUREBLOBCONTAINERSASURL = "?sv=2000-01-01&sr=c&st=2000-01-01&se=2000-01-01&sp=racwl&spr=https&sig=33xSIEP1AhFQXVFdn2FHs08bfHDT%2B68hll1Iognu1AU%3D"
    EMAIL_APIKEY                                   = var.secret_applink_cloud_email_apikey
    KOS_INFO_ACTIVE                                = false
    APP_URL                                        = "https://${local.appcore_fqdn}/applinkcloud/"
    APPLICATIONINSIGHTS_CONNECTION_STRING          = azurerm_application_insights.applink_cloud.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION     = 3
    LIST_applink_ONPREM_LOG_ANALYTICS_WORKSPACE_ID = jsonencode(local.map_list_applink_onprem_log_analytics_workspaces) # because map_list_log_analytics_workspaces is of type map, it must be converted using jsonencode
    # Ref: https://dev.to/jmarhee/working-with-maps-in-terraform-templates-as-json-2g36
    LIST_applink_ONPREM_APP_INSIGHTS_CONNECTION_STRING = jsonencode(local.map_list_applink_onprem_app_insights_connection_strings)
    LIST_applink_ONPREM_APP_INSIGHTS_APP_ID            = jsonencode(local.map_list_applink_onprem_app_insights_app_ids)
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
  depends_on = [
    azurerm_service_plan.appcore_service_plan,
    azurerm_storage_account.appcore,
    azurerm_log_analytics_workspace.applink_cloud,
  ]
}
