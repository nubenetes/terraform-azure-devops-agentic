# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/website/docs/r/application_gateway.html.markdown
# https://shisho.dev/dojo/providers/azurerm/Network/azurerm-application-gateway/
# https://github.com/amalaguti/training-tf/blob/63117824cd8e7edeccc8d8bec5e9f5645be2fdaa/application-gateway/app_gateway.tf#L1
# https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/ssl-cert
# https://www.nathannellans.com/post/azure-application-gateway-part-1

######################################################################################################################################
# Application Gateway configuration overview 🌟 https://docs.microsoft.com/en-us/azure/application-gateway/configuration-overview
######################################################################################################################################

####################################################################
# youtube: App Service Application Gateway Configuration 🌟🌟🌟
# https://www.youtube.com/watch?v=x2S8EFkh8PU
####################################################################

######################################################################################################################################
# TLS termination with Key Vault certificates 🌟 https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs
# The Azure portal supports only Key Vault certificates, not secrets. Application Gateway still supports referencing secrets from Key Vault,
# but only through non-portal resources like PowerShell, the Azure CLI, APIs, and Azure Resource Manager templates (ARM templates).
#
# Azure Application Gateway supports integration with Key Vault for server certificates that are attached to HTTPS-enabled listeners.
# This support is limited to the v2 SKU of Application Gateway.
######################################################################################################################################

##########################################################################################################################################################################################
# Delegate user-assigned managed identity to Key Vault: If you're using Azure role-based access control follow the article Assign a managed identity access to a resource and assign the
# user-assigned managed identity the Key Vault Secrets User role to the Azure Key Vault. https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/howto-assign-access-portal
##########################################################################################################################################################################################

# Examples:
# https://github.com/Azure/terraform/tree/master/quickstart/101-application-gateway
# https://github.com/kumarvna/terraform-azurerm-application-gateway
# https://www.anycodings.com/1questions/1465804/terraform-dynamic-block-content-in-conditional-way

#####################################################################################################################################################
# Create certificates to allow the backend with Azure Application Gateway
# https://learn.microsoft.com/en-us/azure/application-gateway/certificates-for-backend-authentication
# To do end to end TLS, Application Gateway requires the backend instances to be allowed by uploading authentication/trusted root certificates.
# For the v1 SKU, authentication certificates are required, but for the v2 SKU trusted root certificates are required to allow the certificates.
#
# TRUSTED ROOT CERTIFICATES AND SELF SIGNED CERTIFICATES:
# Generate an Azure Application Gateway self-signed certificate with a custom root CA
# https://learn.microsoft.com/en-us/azure/application-gateway/self-signed-certificates
#
# The Application Gateway v2 SKU introduces the use of Trusted Root Certificates to allow backend servers. This removes authentication certificates that were required in the v1 SKU.
# The root certificate is a Base-64 encoded X.509(.CER) format root certificate from the backend certificate server. It identifies the root certificate authority (CA) that issued the
# server certificate and the server certificate is then used for the TLS/SSL communication.
#
# Application Gateway trusts your website's certificate by default if it's signed by a well-known CA (for example, GoDaddy or DigiCert). You don't need to explicitly upload the root certificate
# in that case. For more information, see Overview of TLS termination and end to end TLS with Application Gateway. However, if you have a dev/test environment and don't want to purchase a verified CA
# signed certificate, you can create your own custom CA and create a self-signed certificate with it.
#
# Add Backend setting
# For end-to-end SSL encryption, the backends must be in the allowlist of the application gateway. Upload the public certificate of the backend servers to this Backend setting.
##################################################################################################################################################################################

# Application Gateway request routing rules:
# https://learn.microsoft.com/en-us/azure/application-gateway/configuration-request-routing-rules

resource "azurerm_application_gateway" "appcore_agw" {
  name                = "agw-${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.appcore_rg.name
  location            = local.location
  enable_http2        = true
  tags                = local.tags
  sku { # TLS termination with Key Vault certificates is limited to the v2 SKUs.
    # https://azure.microsoft.com/en-us/pricing/details/application-gateway/
    name = "WAF_v2" # v2 SKU with WAF enabled
    tier = "WAF_v2" # v2 SKU with WAF enabled
    # name      = "Standard_v2"
    # tier      = "Standard_v2"
  }
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  ###########################################################################################################################
  # Check your wildcard certificate (i.e. app-envdev.deng.enterprise.com):
  #    https://www.sslshopper.com/ssl-checker.html
  #    https://www.ssllabs.com/ssltest/
  # Outcome: The certificate is not trusted in all web browsers. You may need to install an
  # intermediate/chain certificate to link it to a trusted root certificate.
  # Ref:
  #   https://stackoverflow.com/questions/58269743/issue-within-certification-chain-using-azure-application-gateway
  #   Gateway V2: the importance of the certificate chain: http://blog.repsaj.nl/index.php/2019/08/azure-application-gateway-certificate-gotchas/
  #     The problem was with the fact that our PFX we were using did not contain the full chain of the certificate.
  #     For the V1 gateway this didn’t matter, but for V2 this does.
  #     So again the fix for this issue was a lot simpler than finding the actual issue: we exported the certificate again using the “Include all certificates in the certification path if possible” option.
  #     This will create a PFX including the certificate chain.
  ###########################################################################################################################
  # trusted_root_certificate  {
  #   name                = "TrustedRoot"
  #   key_vault_secret_id = azurerm_key_vault_certificate.Enterprise_wildcard.secret_id
  #   # The Secret ID of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for the Key Vault to use this feature.
  # }
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
    name = "port_443"
    port = 443
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  ssl_certificate {
    # https://www.anycodings.com/questions/terraform-how-to-attach-ssl-certificate-stored-in-azure-keyvault-to-an-application-gateway
    name                = azurerm_key_vault_certificate.Enterprise_wildcard.name
    key_vault_secret_id = azurerm_key_vault_certificate.Enterprise_wildcard.secret_id
    #password            = var.secret_certificate_passphrase
  }
  identity {
    identity_ids = [azurerm_user_assigned_identity.appcore_agw.id]
    type         = "UserAssigned"
  }
  backend_address_pool {
    name  = "bp-back"
    fqdns = ["${local.app_name_appcore_back_api}.azurewebsites.net"]
  }
  backend_address_pool {
    name  = "bp-front"
    fqdns = ["${local.app_name_appcore_front_spa}.azurewebsites.net"]
  }
  backend_address_pool {
    name  = "bp-applink-cloud"
    fqdns = ["${local.app_name_applink_cloud_api}.azurewebsites.net"]
  }
  backend_address_pool {
    name  = "bp-pdf-renderer"
    fqdns = ["${local.app_name_pdf_renderer}.azurewebsites.net"]
  }
  backend_http_settings {
    name                                = "hss-front"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-front"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    name                                = "hss-back"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/core/"
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-back"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    name                                = "hss-applink-cloud"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/" # Do not use "/applinkcloud/" here, it won't work !
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-applink-cloud"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    name                                = "hss-pdf-renderer"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-pdf-renderer"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  backend_http_settings {
    name                                = "hss-viewer"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/" #"/pvf/"    # pvf = portal viewer frontend
    pick_host_name_from_backend_address = true
    port                                = 443
    probe_name                          = "hp-viewer"
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  http_listener {
    name                           = "lhs-portal"
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_443"
    host_names                     = ["${local.appcore_dns_name}.${local.dns_zone}"]
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.Enterprise_wildcard.name
  }
  http_listener {
    name                           = "lh-portal"
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_80"
    host_names                     = ["*.${local.dns_zone}"]
    protocol                       = "Http"
  }
  probe {
    name                                      = "hp-front"
    interval                                  = 30
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
  probe {
    name                                      = "hp-back"
    interval                                  = 30
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
    name                                      = "hp-applink-cloud"
    interval                                  = 30
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
  probe {
    name                                      = "hp-pdf-renderer"
    interval                                  = 30
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
  probe {
    name                                      = "hp-viewer"
    interval                                  = 30
    path                                      = "/" #"/pvf/"
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
    name                 = "rch-portal"
    target_listener_name = "lhs-portal"
    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
  }
  request_routing_rule {
    name                        = "rrh-portal"
    redirect_configuration_name = "rch-portal"
    http_listener_name          = "lh-portal"
    priority                    = 10
    rewrite_rule_set_name       = "rh-default"
    rule_type                   = "Basic" # https://learn.microsoft.com/en-us/azure/application-gateway/configuration-http-settings#override-backend-path
  }
  request_routing_rule {
    name               = "rrhs-portal"
    url_path_map_name  = "rrhs-portal"
    http_listener_name = "lhs-portal"
    priority           = 20
    rule_type          = "PathBasedRouting" # https://learn.microsoft.com/en-us/azure/application-gateway/configuration-http-settings#override-backend-path
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
    name                               = "rrhs-portal"
    default_backend_address_pool_name  = "bp-front"
    default_backend_http_settings_name = "hss-front"
    default_rewrite_rule_set_name      = "rh-default"
    path_rule {
      name                       = "pr-back"
      backend_address_pool_name  = "bp-back"
      backend_http_settings_name = "hss-back"
      paths                      = ["/core*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      name                       = "pr-applink-cloud"
      backend_address_pool_name  = "bp-applink-cloud"
      backend_http_settings_name = "hss-applink-cloud"
      paths                      = ["/applinkcloud*"]
      rewrite_rule_set_name      = "rh-default"
    }
    path_rule {
      name                       = "pr-pdf-renderer"
      backend_address_pool_name  = "bp-pdf-renderer"
      backend_http_settings_name = "hss-pdf-renderer"
      paths                      = ["/report/pdf*"]
      rewrite_rule_set_name      = "rh-default"
    }
    ##############################################################################
    # Viewer - clients: Redirect to different Listener
    # https://www.nathannellans.com/post/azure-application-gateway-part-1
    #############################################################################
    path_rule {
      name                        = "pr-viewer"
      redirect_configuration_name = "rchs-portal_rr-viewer"
      paths                       = ["/pvf*"] # pvf = portal viewer frontend
      rewrite_rule_set_name       = "rh-default"
    }
  }
  ####################
  # Viewer - clients:
  ####################
  frontend_port {
    name = "port_4200"
    port = 4200
  }
  dynamic "backend_address_pool" {
    for_each = var.client_names
    iterator = myclient
    content {
      name  = "bp-viewer-back-${myclient.value}"
      fqdns = ["app-${var.Enterprise_product}-${var.app-analysis-service_name}-viewer-back-${myclient.value}-${local.gitbranch}${var.location_code}${var.environment}.azurewebsites.net"]
      # Make sure the above fqdns setting matches azurerm_linux_web_app.app-analysis_viewer_back_api_myclient.name !!
    }
  }
  backend_address_pool {
    name  = "bp-viewer-front"
    fqdns = ["${local.app_name_analysis_viewer_front_spa}.azurewebsites.net"]
  }
  http_listener {
    name                           = "lhs-viewer"
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = "port_443"
    host_names                     = ["${local.app-analysis_viewer_dns_name}.${local.dns_zone}"]
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = azurerm_key_vault_certificate.Enterprise_wildcard.name
  }
  request_routing_rule {
    name               = "rrhs-viewer"
    url_path_map_name  = "rrhs-viewer"
    http_listener_name = "lhs-viewer"
    priority           = 30
    rule_type          = "PathBasedRouting" # https://learn.microsoft.com/en-us/azure/application-gateway/configuration-http-settings#override-backend-path
  }
  url_path_map {
    name                               = "rrhs-viewer"
    default_backend_address_pool_name  = "bp-viewer-front"
    default_backend_http_settings_name = "hss-viewer-front"
    default_rewrite_rule_set_name      = "rh-default"
    dynamic "path_rule" {
      for_each = var.client_names
      content {
        name                       = "pr-viewer-back-${path_rule.value}"
        backend_address_pool_name  = "bp-viewer-back-${path_rule.value}"
        backend_http_settings_name = "hss-viewer-back-${path_rule.value}"
        paths                      = ["/pvb/${path_rule.value}/*"] # pvb = portal viewer backend
      }
    }
  }
  redirect_configuration {
    name                 = "rchs-portal_rr-viewer"
    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
    target_listener_name = "lhs-viewer"
  }
  # Viewer Frontend :
  backend_http_settings {
    name                                = "hss-viewer-front"
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    pick_host_name_from_backend_address = true
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 1800
  }
  dynamic "backend_http_settings" {
    for_each = var.client_names
    content {
      name                                = "hss-viewer-back-${backend_http_settings.value}"
      affinity_cookie_name                = "ApplicationGatewayAffinity"
      cookie_based_affinity               = "Disabled"
      path                                = "/" #"/pvb/${backend_http_settings.value}/"
      pick_host_name_from_backend_address = true
      port                                = 443
      protocol                            = "Https"
      request_timeout                     = 1800
    }
  }
  dynamic "probe" {
    for_each = var.client_names
    iterator = myclient
    content {
      name                                      = "hp-viewer-back-${myclient.value}"
      interval                                  = 30
      path                                      = "/" #"/pvb/${myclient.value}"
      pick_host_name_from_backend_http_settings = true
      protocol                                  = "Https"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      match {
        body        = ""
        status_code = ["200-399"]
      }
    }
  }
  depends_on = [
    azurerm_key_vault_certificate.Enterprise_wildcard,
    azurerm_linux_web_app.appcore_back_api,
    azurerm_linux_web_app.appcore_front_spa,
    azurerm_linux_web_app.applink_cloud_api,
    azurerm_linux_web_app.app-analysis_pdf_renderer,
    azurerm_linux_web_app.app-analysis_viewer_front_spa,
    azurerm_linux_web_app.app-analysis_viewer_back_api_myclient,
    azurerm_user_assigned_identity.appcore_agw,
    azurerm_subnet.appcore_agw,
    azurerm_public_ip.appcore_agw,
    #azurerm_subnet_route_table_association.appcore_agw,
  ]
}
