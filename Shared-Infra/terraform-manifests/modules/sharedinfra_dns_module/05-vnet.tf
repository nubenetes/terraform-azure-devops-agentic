# resource "azurerm_virtual_network" "my_vnet" {
#   name                = "vnet-${var.Enterprise_product}-${local.gitbranch}${var.location_code}${var.environment}"
#   location            = local.location
#   resource_group_name = azurerm_resource_group.sharedinfra_rg.name
#   address_space       = ["${var.vnet_cidr}"]
#   tags                = local.tags
#   depends_on = [
#     azurerm_resource_group.sharedinfra_rg,
#   ]
# }


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers
# NOTE on Virtual Networks and DNS Servers:
# Terraform currently provides both a standalone virtual network DNS Servers resource, and allows for DNS servers to be defined in-line within 
# the Virtual Network resource. At this time you cannot use a Virtual Network with in-line DNS servers in conjunction with any 
# Virtual Network DNS Servers resources. Doing so will cause a conflict of Virtual Network DNS Servers configurations and will overwrite 
# virtual networks DNS servers.
#
# resource "azurerm_virtual_network_dns_servers" "example" {
#   virtual_network_id = azurerm_virtual_network.example.id
#   dns_servers        = ["127.0.0.1", "127.0.0.1", "127.0.0.1"]
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

