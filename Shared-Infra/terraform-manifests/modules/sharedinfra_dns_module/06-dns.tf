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

##################################################################################################################################
# DNS ZONE 
# https://learn.microsoft.com/en-us/answers/questions/653710/azure-dns-shared-with-other-subscription.html
# https://dzone.com/refcardz/dns
# https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns
# https://learn.microsoft.com/en-us/azure/dns/tutorial-public-dns-zones-child
##################################################################################################################################
resource "azurerm_dns_zone" "my_dns" {
  name                = local.dns_zone
  resource_group_name = azurerm_resource_group.sharedinfra_rg.name
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
  # soa_record {
  #   #email = "adminit.${local.dns_zone}"
  #   email = "adminit.enterprise.com"  # required      
  #   host_name = "ns1-35.azure-dns.com." # required
  #   expire_time = 300 # optional 
  #   minimum_ttl = 300 # optional
  #   refresh_time = 120 # optional 
  #   retry_time = 120 # optional 
  #   #serial_number = # optional 
  #   ttl = 300 # optional 
  #   #tags = local.tags # optional 
  # }
  depends_on = [
    azurerm_resource_group.sharedinfra_rg,
    #azurerm_virtual_network.my_vnet,
  ]
}

resource "azurerm_dns_txt_record" "example" {
  name                = "info"
  zone_name           = azurerm_dns_zone.my_dns.name
  resource_group_name = azurerm_resource_group.sharedinfra_rg.name
  ttl                 = 300
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
  record {
    value = "${local.dns_zone} subdomain - ${var.environment} environment"
  }
}
