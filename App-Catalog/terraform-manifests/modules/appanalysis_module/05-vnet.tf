resource "azurerm_virtual_network" "my_vnet" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "vnet-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  address_space       = ["${var.vnet_cidr}"]
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
  ]
}

resource "azurerm_subnet" "App-Catalog_agw" {
  for_each            = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                = "snet-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  #virtual_network_name = "vnet-${var.Enterprise_product}-${each.value}-${var.environment}-${local.location}"
  virtual_network_name = azurerm_virtual_network.my_vnet[each.key].name
  address_prefixes     = ["${var.subnet_cidr}"]
  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
    azurerm_virtual_network.my_vnet,
  ]
}

resource "azurerm_public_ip" "App-Catalog_agw" {
  #for_each            = toset(var.client_names)    # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  for_each            = toset([for c in var.client_names : c if contains(var.client_names_with_enabled_app_gateways, c)])
  name                = "pip-agw-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.App-Catalog_rg,
  ]
  # agw-app-analysis-myclient-dev with SKU Standard_v2 can only reference public ip with Standard SKU
  # Static IP allocation must be used when creating Standard SKU public IP addresses
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers
# NOTE on Virtual Networks and DNS Servers:
# Terraform currently provides both a standalone virtual network DNS Servers resource, and allows for DNS servers to be defined in-line within
# the Virtual Network resource. At this time you cannot use a Virtual Network with in-line DNS servers in conjunction with any
# Virtual Network DNS Servers resources. Doing so will cause a conflict of Virtual Network DNS Servers configurations and will overwrite
# virtual networks DNS servers.
#
# resource "azurerm_virtual_network_dns_servers" "my_vnet" {
#   for_each            = toset(var.client_names)
#   virtual_network_id  = azurerm_virtual_network.my_vnet[each.key].id
#   dns_servers        = ["127.0.0.1","127.0.0.1"] # ns1-38.azure-dns.com , ns2-38.azure-dns.net
# }

# Parameters:
# The following arguments are supported:
#   - virtual_network_id - (Required) The ID of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created.
#   - dns_servers - (Required) List of IP addresses of DNS servers
# The following attributes are exported:
#   - id - The virtual network DNS server ID.

# Tips: Best Practices for The Other Azure Network Resources
# https://shisho.dev/dojo/providers/azurerm/Network/azurerm-virtual-network-dns-servers/
