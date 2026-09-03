# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/application_gateway.html.markdown
# https://shisho.dev/dojo/providers/azurerm/Network/azurerm-application-gateway/
# https://github.com/amalaguti/training-tf/blob/63117824cd8e7edeccc8d8bec5e9f5645be2fdaa/application-gateway/app_gateway.tf#L1

#https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/ssl-cert

# Application Gateway configuration overview 🌟 https://docs.microsoft.com/en-us/azure/application-gateway/configuration-overview

# TLS termination with Key Vault certificates 🌟 https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs
# The Azure portal supports only Key Vault certificates, not secrets. Application Gateway still supports referencing secrets from Key Vault,
# but only through non-portal resources like PowerShell, the Azure CLI, APIs, and Azure Resource Manager templates (ARM templates).
#
# Delegate user-assigned managed identity to Key Vault: If you're using Azure role-based access control follow the article Assign a managed identity access to a resource and assign the
# user-assigned managed identity the Key Vault Secrets User role to the Azure Key Vault. https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/howto-assign-access-portal

# To do: Add a flag to each deployment settings in order to include a dedicated App Gateway instance (i.e in Novartis)

resource "azurerm_application_gateway" "App-Catalog_agw" {
  for_each            = toset([for c in var.client_names : c if contains(var.client_names_with_enabled_app_gateways, c)])
  name                = "agw-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  location            = local.location
  enable_http2        = true
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  autoscale_configuration {
    max_capacity = 10
    min_capacity = 0
  }
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.App-Catalog_agw[each.key].id
  }
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.App-Catalog_agw[each.key].id
  }
  frontend_port {
    name = var.frontend_port_name
    port = 80
  }
  frontend_port {
    name = var.frontend_port_name_secure
    port = 443
  }
  backend_address_pool {
    name  = var.backend_address_pool_name
    fqdns = ["app-omni-${var.Enterprise_product}-${each.value}-${local.gitbranch}${var.environment}.azurewebsites.net"]
  }
  backend_http_settings {
    name                                = var.backend_http_settings_name
    probe_name                          = var.probe_name
    cookie_based_affinity               = "Enabled"
    affinity_cookie_name                = var.cookie_name
    path                                = "/"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
    pick_host_name_from_backend_address = true
    #pick_host_name_from_backend_address = false
    ## myHTTPSsetting' is not allowed to have PickHostNameFromBackendHttpSettings set to true. It may only be set to true if Backend Http Settings defines
    ## the 'HostName' property or sets 'PickHostNameFromBackendAddress' to true.
  }
  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }
  request_routing_rule {
    name                        = var.request_routing_rule_name
    http_listener_name          = var.listener_name
    redirect_configuration_name = var.redirect_configuration_name
    rule_type                   = "Basic"
    priority                    = 20
  }

  http_listener {
    name                           = var.listener_name_secure
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name_secure
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.Enterprise_wildcard[each.key].name
  }
  redirect_configuration {
    name                 = var.redirect_configuration_name
    target_listener_name = var.listener_name_secure
    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
  }
  request_routing_rule {
    name                       = var.request_routing_rule_name_secure
    http_listener_name         = var.listener_name_secure
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.backend_http_settings_name
    rule_type                  = "Basic"
    priority                   = 40
  }
  probe {
    name                                      = var.probe_name
    protocol                                  = "Https"
    pick_host_name_from_backend_http_settings = true
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      body        = ""
      status_code = []
    }
  }
  ssl_certificate {
    # https://www.anycodings.com/questions/terraform-how-to-attach-ssl-certificate-stored-in-azure-keyvault-to-an-application-gateway
    name                = azurerm_key_vault_certificate.Enterprise_wildcard[each.key].name
    key_vault_secret_id = azurerm_key_vault_certificate.Enterprise_wildcard[each.key].secret_id
    password            = ""
  }
  identity {
    identity_ids = [azurerm_user_assigned_identity.App-Catalog_agw[each.key].id]
    type         = "UserAssigned"
  }
  depends_on = [
    azurerm_key_vault_certificate.Enterprise_wildcard,
    azurerm_linux_web_app.App-Catalog,
    azurerm_linux_web_app.monitor_client,
    azurerm_user_assigned_identity.App-Catalog_agw,
    azurerm_subnet.App-Catalog_agw,
  ]
}
