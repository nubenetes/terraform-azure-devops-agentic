# Boilerplates:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/app-service

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app


###################################
# DNS
##################################
resource "azurerm_dns_a_record" "myclient_with_agw" {
  for_each = toset([for c in var.client_names : c if contains(var.client_names_with_enabled_app_gateways, c)])
  name     = "${each.value}${var.dns_prefix}${local.gitbranch}${local.env_generator}"
  # client-anon-catadev     ${each.value}-${var.dns_prefix}${local.env_generator}.${var.dns_zone}
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300 # 5 min
  target_resource_id  = azurerm_public_ip.App-Catalog_agw[each.key].id
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  depends_on = [
    azurerm_public_ip.App-Catalog_agw,
  ]
}


###################################################################################################################
# https://stackoverflow.com/questions/48642411/create-custom-domain-for-app-services-via-terraform
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_managed_certificate
###################################################################################################################

resource "azurerm_dns_txt_record" "domain-verification" {
  for_each = toset([for c in var.client_names : c if !contains(var.client_names_with_enabled_app_gateways, c)])
  #name                = "asuid.${azurerm_linux_web_app.App-Catalog[each.key].name}.${local.dns_zone}"
  name                = "asuid.${each.value}${var.dns_prefix}${local.gitbranch}${local.env_generator}"
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300

  record {
    value = azurerm_linux_web_app.App-Catalog[each.key].custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "myclient_without_agw" {
  for_each = toset([for c in var.client_names : c if !contains(var.client_names_with_enabled_app_gateways, c)])
  name     = "${each.value}${var.dns_prefix}${local.gitbranch}${local.env_generator}"
  # client-anoncatadev     ${each.value}${var.dns_prefix}${local.env_generator}.${var.dns_zone}
  # dns name without hyphen in an attempt to avoid being backlisted by Google (Deceptive Site Ahead)
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300
  record              = azurerm_linux_web_app.App-Catalog[each.key].default_hostname
  depends_on          = [azurerm_dns_txt_record.domain-verification]
}

#######################################
# pushgateway
#######################################
resource "azurerm_dns_cname_record" "pushgateway" {
  name      = "${var.dns_prefix}${local.gitbranch}${local.env_generator}-pushgateway"
  zone_name = local.dns_zone
  #resource_group_name = azurerm_dns_zone.my_dns[each.key].resource_group_name
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300 # 5 min
  record              = var.prometheus_push_gateway
  tags                = local.tags
  depends_on = [
    azurerm_public_ip.App-Catalog_agw,
  ]
}

##################################################################################################################################
# DNS ZONE
# https://learn.microsoft.com/en-us/answers/questions/653710/azure-dns-shared-with-other-subscription.html
##################################################################################################################################
# resource "azurerm_dns_zone" "my_dns" {
#   for_each            = toset(var.client_names)
#   name                = var.dns_zone
#   resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
#   tags                = local.tags # optional
#   # soa_record {
#   #   #email = "adminit.${var.dns_zone}"
#   #   email = "adminit.enterprise.com"  # required
#   #   host_name = "ns1-36.azure-dns.com." # required
#   #   expire_time = 300 # optional
#   #   minimum_ttl = 300 # optional
#   #   refresh_time = 120 # optional
#   #   retry_time = 120 # optional
#   #   #serial_number = # optional
#   #   ttl = 300 # optional
#   #   #tags = local.tags # optional
#   # }
#   depends_on = [
#     azurerm_resource_group.App-Catalog_rg,
#     azurerm_virtual_network.my_vnet,
#   ]
# }

# resource "azurerm_dns_cname_record" "my_dns" {
#   name                = "www"
#   zone_name           = data.azurerm_dns_zone.my_dns.name
#   resource_group_name = data.azurerm_dns_zone.my_dns.resource_group_name
#   ttl                 = 300
#   record              = azurerm_linux_web_app.App-Core.default_hostname
# }

# resource "azurerm_dns_txt_record" "example" {
#   name                = "asuid.${azurerm_dns_cname_record.example.name}"
#   zone_name           = data.azurerm_dns_zone.example.name
#   resource_group_name = data.azurerm_dns_zone.example.resource_group_name
#   ttl                 = 300
#   record {
#     value = azurerm_app_service.example.custom_domain_verification_id
#   }
# }
