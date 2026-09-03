# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers
# NOTE on Virtual Networks and DNS Servers:
# Terraform currently provides both a standalone virtual network DNS Servers resource, and allows for DNS servers to be defined in-line within
# the Virtual Network resource. At this time you cannot use a Virtual Network with in-line DNS servers in conjunction with any
# Virtual Network DNS Servers resources. Doing so will cause a conflict of Virtual Network DNS Servers configurations and will overwrite
# virtual networks DNS servers.
#
# resource "azurerm_virtual_network_dns_servers" "my_vnet" {
#   virtual_network_id = azurerm_virtual_network.my_vnet.id
#   dns_servers        = ["127.0.0.1","127.0.0.1"]  # ns1-38.azure-dns.com , ns2-38.azure-dns.net
# }
#
# Parameters:
# The following arguments are supported:
#   - virtual_network_id - (Required) The ID of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created.
#   - dns_servers - (Required) List of IP addresses of DNS servers
# The following attributes are exported:
#   - id - The virtual network DNS server ID.

# Tips: Best Practices for The Other Azure Network Resources
# https://shisho.dev/dojo/providers/azurerm/Network/azurerm-virtual-network-dns-servers/


###################################
# DNS
##################################
resource "azurerm_dns_a_record" "appcore" {
  name                = local.appcore_dns_name
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300 # 5 min
  target_resource_id  = azurerm_public_ip.appcore_agw.id
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
  depends_on = [
    azurerm_public_ip.appcore_agw,
  ]
}

resource "azurerm_dns_a_record" "myclient" {
  for_each            = toset(var.client_names)
  name                = "${each.value}-${var.dns_prefix}${local.gitbranch}${var.dns_location_code}${local.env_generator}"
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300 # 5 min
  target_resource_id  = azurerm_public_ip.appcore_agw.id
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
  depends_on = [
    azurerm_public_ip.appcore_agw,
  ]
}

###################################################################
# app-analysis Viewer DNS Name
###################################################################
resource "azurerm_dns_a_record" "app-analysis_viewer" {
  name                = local.app-analysis_viewer_dns_name
  zone_name           = local.dns_zone
  resource_group_name = local.dns_zone_resource_group_name
  ttl                 = 300 # 5 min
  target_resource_id  = azurerm_public_ip.appcore_agw.id
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
  depends_on = [
    azurerm_public_ip.appcore_agw,
  ]
}