# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/application_gateway.html.markdown
# https://shisho.dev/dojo/providers/azurerm/Network/azurerm-application-gateway/
# https://github.com/amalaguti/training-tf/blob/63117824cd8e7edeccc8d8bec5e9f5645be2fdaa/application-gateway/app_gateway.tf#L1

#https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/ssl-cert

resource "azurerm_application_gateway" "appcore_agw" {
  name                = "agw-${var.Enterprise_product}-${var.environment}"
  resource_group_name = azurerm_resource_group.appcore_rg.name
  location            = local.location #"northeurope"
  tags                = local.tags

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  autoscale_configuration {
    max_capacity = 10
    min_capacity = 0
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.appcore_agw.id
  }
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appcore_agw.id
  }
  frontend_port {
    name = "port_4200"
    port = 4200
  }
  frontend_port {
    name = "port_443"
    port = 443
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  ssl_certificate {
    name = azurerm_key_vault_certificate.appcore_certificate.name # Prod Environment: wildcard certificate
    #data      = filebase64("certificate.pfx")
    data     = var.secret_appGatewayListenerSecure
    password = ""
  }
  identity {
    identity_ids = [azurerm_user_assigned_identity.appcore_agw.id]
    type         = "UserAssigned"
  }
  backend_address_pool {
    fqdns = ["app-core-portal-backend-${var.environment}.azurewebsites.net"]
    name  = "bp-core-portal-backend"
  }
  backend_address_pool {
    fqdns = ["app-core-portal-frontend-${var.environment}.azurewebsites.net"]
    name  = "bp-core-portal-frontend"
  }
  backend_address_pool {
    fqdns = ["app-corelink-cloud-core-${var.environment}.azurewebsites.net"]
    name  = "bp-applink-cloud-core"
  }
  backend_address_pool {
    fqdns = ["app-pdf-renderer-core-${var.environment}.azurewebsites.net"]
    name  = "bp-pdf-renderer-core"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-Enterprise-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-Enterprise"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-Enterpriseux-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-Enterpriseux"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-rajgupta-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-rajgupta"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-backend-client-example-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-backend-client-example"
  }
  backend_address_pool {
    fqdns = ["app-analysis-viewer-frontend-${var.environment}.azurewebsites.net"]
    name  = "bp-analysis-viewer-frontend"
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-core-portal-backend"
    path                                = "/core/"
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-core-portal-backend"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-core-portal-frontend"
    pick_host_name_from_backend_address = true
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-applink-cloud-core"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-applink-cloud-core"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-pdf-renderer-core"
    pick_host_name_from_backend_address = true
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-analysis-viewer-backend"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    name                                = "hss-analysis-viewer-frontend"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_4200"
    host_names                     = ["client-example.${var.environment}enterprise.com", "core.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com"]
    name                           = "lhs-analysis-viewer"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.appcore_certificate.name
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_4200"
    host_names                     = ["client-example.${var.environment}enterprise.com", "client-examplecore.${var.environment}enterprise.com"]
    name                           = "lhs-analysis-viewer-002"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.appcore_certificate.name
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_443"
    host_names                     = ["client-example.${var.environment}enterprise.com", "core.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com"]
    name                           = "lhs-core-portal"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.appcore_certificate.name
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_443"
    host_names                     = ["client-example.${var.environment}enterprise.com", "client-examplecore.${var.environment}enterprise.com"]
    name                           = "lhs-core-portal-002"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.appcore_certificate.name
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_80"
    host_names                     = ["client-example.${var.environment}enterprise.com", "core.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com", "client-example.${var.environment}enterprise.com"]
    name                           = "lh-core-portal"
    protocol                       = "Http"
  }
  http_listener {
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_80"
    host_names                     = ["client-example.${var.environment}enterprise.com", "client-examplecore.${var.environment}enterprise.com"]
    name                           = "lh-core-portal-002"
    protocol                       = "Http"
  }
  probe {
    interval                                  = 30
    name                                      = "hp-core-portal-backend"
    path                                      = "/core/"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Https"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      body        = ""
      status_code = ["200-399"]
    }
  }
  probe {
    interval                                  = 30
    name                                      = "hp-applink-cloud-core"
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Https"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      body        = ""
      status_code = ["200-399"]
    }
  }
  redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "rrh-core-portal"
    redirect_type        = "Permanent"
    target_listener_name = "lhs-core-portal"
  }
  redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "rrh-core-portal-002"
    redirect_type        = "Permanent"
    target_listener_name = "lhs-core-portal-002"
  }
  redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "rrhs-core-portal-002_rr-analysis-viewer"
    redirect_type        = "Permanent"
    target_listener_name = "lhs-analysis-viewer"
  }
  redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "rrhs-core-portal_rr-analysis-viewer"
    redirect_type        = "Permanent"
    target_listener_name = "lhs-analysis-viewer"
  }
  request_routing_rule {
    http_listener_name          = "lh-core-portal"
    name                        = "rrh-core-portal"
    priority                    = 10
    redirect_configuration_name = "rrh-core-portal"
    rewrite_rule_set_name       = "rh-default"
    rule_type                   = "Basic"
  }
  request_routing_rule {
    http_listener_name          = "lh-core-portal-002"
    name                        = "rrh-core-portal-002"
    priority                    = 40
    redirect_configuration_name = "rrh-core-portal-002"
    rule_type                   = "Basic"
  }
  request_routing_rule {
    http_listener_name = "lhs-core-portal"
    name               = "rrhs-core-portal"
    priority           = 20
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "rrhs-core-portal"
  }
  request_routing_rule {
    http_listener_name = "lhs-core-portal-002"
    name               = "rrhs-core-portal-002"
    priority           = 50
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "rrhs-core-portal-002"
  }
  request_routing_rule {
    http_listener_name = "lhs-analysis-viewer"
    name               = "rrhs-analysis-viewer"
    priority           = 30
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "rrhs-analysis-viewer"
  }
  request_routing_rule {
    http_listener_name = "lhs-analysis-viewer-002"
    name               = "rrhs-analysis-viewer-002"
    priority           = 60
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "rrhs-analysis-viewer-002"
  }
  rewrite_rule_set {
    name = "rh-default"
    rewrite_rule {
      name          = "rrn-server"
      rule_sequence = 100
      response_header_configuration {
        header_name  = "Server"
        header_value = "Enterprise"
      }
    }
  }
  url_path_map {
    default_backend_address_pool_name  = "bp-core-portal-frontend"
    default_backend_http_settings_name = "hss-core-portal-frontend"
    default_rewrite_rule_set_name      = "rh-default"
    name                               = "rrhs-core-portal"
    path_rule {
      backend_address_pool_name  = "bp-applink-cloud-core"
      backend_http_settings_name = "hss-applink-cloud-core"
      name                       = "rr-applink-cloud-core"
      paths                      = ["/applinkcloud*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-pdf-renderer-core"
      backend_http_settings_name = "hss-pdf-renderer-core"
      name                       = "rr-pdf-renderer-core"
      paths                      = ["/report/pdf*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      name                        = "rr-analysis-viewer"
      paths                       = ["/pvf*"]
      redirect_configuration_name = "rrhs-core-portal_rr-analysis-viewer"
      rewrite_rule_set_name       = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-core-portal-backend"
      backend_http_settings_name = "hss-core-portal-backend"
      name                       = "rr-core-portal-backend"
      paths                      = ["/core*"]
      rewrite_rule_set_name      = "rh-default"
    }
  }
  url_path_map {
    default_backend_address_pool_name  = "bp-core-portal-frontend"
    default_backend_http_settings_name = "hss-core-portal-frontend"
    name                               = "rrhs-core-portal-002"
    path_rule {
      backend_address_pool_name  = "bp-applink-cloud-core"
      backend_http_settings_name = "hss-applink-cloud-core"
      name                       = "rr-applink-cloud-core"
      paths                      = ["/applinkcloud*"]
    }
    path_rule {
      backend_address_pool_name  = "bp-pdf-renderer-core"
      backend_http_settings_name = "hss-pdf-renderer-core"
      name                       = "rr-pdf-renderer-core"
      paths                      = ["/report/pdf*"]
    }
    path_rule {
      backend_address_pool_name  = "bp-core-portal-backend"
      backend_http_settings_name = "hss-core-portal-backend"
      name                       = "rr-core-portal-backend"
      paths                      = ["/core*"]
    }
    path_rule {
      name                        = "rr-analysis-viewer"
      paths                       = ["/pvf*"]
      redirect_configuration_name = "rrhs-core-portal-002_rr-analysis-viewer"
    }
  }
  url_path_map {
    default_backend_address_pool_name  = "bp-analysis-viewer-frontend"
    default_backend_http_settings_name = "hss-analysis-viewer-frontend"
    name                               = "rrhs-analysis-viewer-002"
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
    }
  }
  url_path_map {
    default_backend_address_pool_name  = "bp-analysis-viewer-frontend"
    default_backend_http_settings_name = "hss-analysis-viewer-frontend"
    default_rewrite_rule_set_name      = "rh-default"
    name                               = "rrhs-analysis-viewer"
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-Enterprise"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-Enterprise"
      paths                      = ["/pvb/Enterprise/*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-rajgupta"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-rajgupta"
      paths                      = ["/pvb/RAJGUPTA/*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-Enterpriseux"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-Enterpriseux"
      paths                      = ["/pvb/EnterpriseUX/*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
    }
    path_rule {
      backend_address_pool_name  = "bp-analysis-viewer-backend-client-example"
      backend_http_settings_name = "hss-analysis-viewer-backend"
      name                       = "rr-analysis-viewer-backend-client-example"
      paths                      = ["/pvb/client-example/*"]
    }
  }

  depends_on = [
    azurerm_key_vault_certificate.appcore_certificate,
  ]

}