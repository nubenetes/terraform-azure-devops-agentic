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
# DNS NS Record on enterprise.com domain
# https://github.com/hashicorp/terraform-provider-azurerm/issues/2877
# https://www.terraform.io/language/meta-arguments/resource-provider
##################################################################################################################################

resource "azurerm_dns_ns_record" "my_env_subdomain_on_parent_domain" {
  name                = local.dns_child_zone
  zone_name           = var.dns_parent_zone
  resource_group_name = "infrastructureresourcegroup"
  ttl                 = 300 # 5 min
  records             = var.dns_zone_name_servers
  tags = {
    Environment = "${local.gitbranch}${var.environment}"
  }
}
