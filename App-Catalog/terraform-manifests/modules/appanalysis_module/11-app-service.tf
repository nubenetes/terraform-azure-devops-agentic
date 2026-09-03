# Boilerplates:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/app-service

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app


###################################
# Service Plan
##################################
resource "azurerm_service_plan" "App-Catalog_service_plan" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "plan-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  location            = local.location
  os_type             = "Linux"
  sku_name            = var.plan_sku #"P1v2"
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
}

############################################################################################################################
# App Service 1: Enterprise AppAnalysis 3.0 (aka OMNI-APPANALYSIS)
# backendPool:  app-omni-app-analysis-myclient
# https://enterprise.atlassian.net/wiki/spaces/DEV/pages/00000000
#
# Docker base image: https://hub.docker.com/r/keymetrics/pm2:8-stretch
#                     The goal of this image is to wrap your applications into a proper Node.js production environment.
#                    Production ready nodeJS Docker image including the PM2 runtime (https://pm2.keymetrics.io/)
#
# Azure App Service:
# https://docs.microsoft.com/en-us/azure/app-service/configure-common
# https://docs.microsoft.com/en-us/troubleshoot/azure/app-service/faqs-app-service-linux
############################################################################################################################
resource "azurerm_linux_web_app" "App-Catalog" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "app-omni-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  service_plan_id     = azurerm_service_plan.App-Catalog_service_plan[each.key].id
  https_only          = true
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  site_config {
    ftps_state = "AllAllowed"
    application_stack {
      docker_image     = var.app_docker_image
      docker_image_tag = var.app_docker_image_tag
    }
  }

  # Obtained from azure portal - rg-catalog-incliva - app-omni-app-analysis-incliva - Diagnose and solve problems - Availability and Performance - Application Logs - Platform Logs:
  # docker run -d
  # --expose=3000
  # --name app-omni-app-analysis-incliva_2_121f6503
  # -e WEBSITES_ENABLE_APP_SERVICE_STORAGE=false
  # -e WEBSITES_PORT=3000
  # -e WEBSITE_SITE_NAME=app-omni-app-analysis-incliva
  # -e WEBSITE_AUTH_ENABLED=False
  # -e WEBSITE_ROLE_INSTANCE_ID=0
  # -e WEBSITE_HOSTNAME=app-omni-app-analysis-incliva.azurewebsites.net
  # -e WEBSITE_INSTANCE_ID=8abbdc668543073fd4dbc9b6900e09b2f327efcf0c94c1b510cf33d0c832cea0
  # -e WEBSITE_USE_DIAGNOSTIC_SERVER=False
  # enterpriseappanalysiscr.azurecr.io/omni:3.0.2

  # https://www.mongodb.com/docs/manual/reference/connection-string/
  # By Default: ?authSource=admin  -> this is why database name is not included in the connection_string
  # /defaultauthdb
  # Optional. The authentication database to use if the connection string includes username:password@ authentication credentials but the authSource option is unspecified.
  # If both authSource and defaultauthdb are unspecified, the client will attempt to authenticate the specified user to the admin database.

  # connection_string {
  # https://docs.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-app-settings
  # For ASP.NET and ASP.NET Core developers, setting connection strings in App Service are like setting them in <connectionStrings> in Web.config, but the values you set in App Service override the ones in Web.config.
  # You can keep development settings (for example, a database file) in Web.config and production secrets (for example, SQL Database credentials) safely in App Service. The same code uses your development settings when you debug locally,
  # and it uses your production secrets when deployed to Azure.
  # For other language stacks, it's better to use app settings instead, because connection strings require special formatting in the variable keys in order to access the values.
  # }
  app_settings = {
    AZURE_CLIENT_ID                 = azuread_application.App-Catalog[each.key].application_id
    AZURE_CLIENT_SECRET             = azuread_application_password.App-Catalog[each.key].value
    AZURE_TENANT_ID                 = var.aad_tenant_id
    DOCKER_REGISTRY_SERVER_PASSWORD = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL      = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
    DOCKER_ENABLE_CI                = var.docker_enable_ci
    K8_CLUSTER_NAME                 = var.k8s_cluster_name
    K8_RESOURCE_GROUP               = var.k8s_resource_group
    #MONGO_URL                           = replace(mongodbatlas_advanced_cluster.cluster[each.key].connection_strings.0.standard_srv, "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
    MONGO_URL      = replace(join("/", [mongodbatlas_advanced_cluster.cluster[each.key].connection_strings.0.standard_srv, "modb-${var.Enterprise_product}-${each.value}"]), "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
    TENANT_ID      = var.aad_tenant_id
    WEBSITES_PORT  = 3000 # This is required for custom containers. To manually configure a custom port, use the EXPOSE instruction in the Dockerfile and the app setting, WEBSITES_PORT, with a port value to bind on the container.
    config_key     = var.secret_app_analysis_config_key
    Enterprise_key = var.secret_app_analysis_config_key
    #LOG_ANALYTICS_WORKSPACE_ID          = azurerm_log_analytics_workspace.App-Core.id
    LOG_ANALYTICS_WORKSPACE_ID = azurerm_log_analytics_workspace.App-Catalog[each.key].workspace_id
    #LOG_ANALYTICS_WORKSPACE_PRIMARY_KEY = azurerm_log_analytics_workspace.App-Catalog[each.key].primary_shared_key
  }

  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
    azurerm_service_plan.App-Catalog_service_plan,
    mongodbatlas_advanced_cluster.cluster,
    azuread_application.App-Catalog,
    azuread_application_password.App-Catalog,
  ]
}

###################################################################################################################
# https://stackoverflow.com/questions/48642411/create-custom-domain-for-app-services-via-terraform
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_managed_certificate
###################################################################################################################
resource "azurerm_app_service_custom_hostname_binding" "App-Catalog" {
  for_each            = toset([for c in var.client_names : c if !contains(var.client_names_with_enabled_app_gateways, c)])
  hostname            = "${each.value}${var.dns_prefix}${local.gitbranch}${local.env_generator}.${local.dns_zone}"
  app_service_name    = azurerm_linux_web_app.App-Catalog[each.key].name
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  depends_on          = [azurerm_dns_cname_record.myclient_without_agw]
}

resource "azurerm_app_service_managed_certificate" "App-Catalog" {
  for_each                   = toset([for c in var.client_names : c if !contains(var.client_names_with_enabled_app_gateways, c)])
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.App-Catalog[each.key].id
}

resource "azurerm_app_service_certificate_binding" "App-Catalog" {
  for_each            = toset([for c in var.client_names : c if !contains(var.client_names_with_enabled_app_gateways, c)])
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.App-Catalog[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.App-Catalog[each.key].id
  ssl_state           = "SniEnabled"
}

#######################################################################################
# App Service 2: Enterprise Monitor Client
# app-monitor-client-myclient
#
# Monitor Client is a custom “Prometheus Exporter” that gathers the metrics of one
# or more “collectors”. These metrics (webApp metrics + platform metrics) are pushed
# from this Monitor Client to a “Prometheus Push Gateway” (“pushing metrics” instead
# of “pulling metrics”). Prometheus Server runs in AKS.
#
# https://enterprise.atlassian.net/wiki/spaces/DEV/pages/00000000
#######################################################################################
resource "azurerm_linux_web_app" "monitor_client" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "app-monitor-client-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  service_plan_id     = azurerm_service_plan.App-Catalog_service_plan[each.key].id
  https_only          = true
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )

  site_config {
    ftps_state = "AllAllowed"
    application_stack {
      docker_image     = var.prometheus_exporter_docker_image
      docker_image_tag = var.prometheus_exporter_docker_image_tag
    }
  }

  # connection_string {
  #   # https://docs.microsoft.com/en-us/azure/app-service/configure-common?tabs=portal#configure-app-settings
  #   # For ASP.NET and ASP.NET Core developers, setting connection strings in App Service are like setting them in <connectionStrings> in Web.config, but the values you set in App Service override the ones in Web.config.
  #   # You can keep development settings (for example, a database file) in Web.config and production secrets (for example, SQL Database credentials) safely in App Service. The same code uses your development settings when you debug locally,
  #   # and it uses your production secrets when deployed to Azure.
  #   # For other language stacks, it's better to use app settings instead, because connection strings require special formatting in the variable keys in order to access the values.
  # }
  app_settings = {
    DOCKER_REGISTRY_SERVER_PASSWORD                = var.secret_docker_registry_server_password
    DOCKER_REGISTRY_SERVER_URL                     = var.docker_registry
    DOCKER_REGISTRY_SERVER_USERNAME                = var.docker_registry_username
    DOCKER_ENABLE_CI                               = var.docker_enable_ci
    MONGO_DB_DATABASE                              = "modb-${var.Enterprise_product}-${each.value}"
    MONGO_DB_URI                                   = replace(mongodbatlas_advanced_cluster.cluster[each.key].connection_strings.0.standard_srv, "mongodb+srv://", "mongodb+srv://${var.mongodb_atlas_dbuser}:${var.secret_mongodb_atlas_dbuser_password}@")
    PUSHGATEWAY_CLIENT                             = "${each.value}"
    PUSHGATEWAY_SOLUTION                           = var.Enterprise_product
    PUSHGATEWAY_URL                                = local.push_gateway_prometheus_metrics
    SERVICE_METRICS_PLATFORM_LIST_COMPONENT1_NAME  = "omni"
    SERVICE_METRICS_PLATFORM_LIST_COMPONENT1_VALUE = "https://${local.env_generator}${var.Enterprise_product}${each.value}.${local.dns_zone}"
  }
  depends_on = [
    azurerm_service_plan.App-Catalog_service_plan,
    azurerm_linux_web_app.App-Catalog,
    mongodbatlas_advanced_cluster.cluster,
  ]
}
