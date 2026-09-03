resource "azurerm_virtual_network" "my_vnet" {
  name                = "vnet-${var.Enterprise_product}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  address_space       = ["${var.vnet_cidr}"]
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}

resource "azurerm_subnet" "appcore_agw" {
  name                 = "snet-${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name  = azurerm_resource_group.appcore_rg.name
  virtual_network_name = "vnet-${var.Enterprise_product}-${local.instance_environment}"
  address_prefixes     = ["${var.subnet_cidr}"]
  depends_on = [
    azurerm_resource_group.appcore_rg,
    azurerm_virtual_network.my_vnet,
  ]
}



##################################################################################################################################
# add a route table with a UDR allowing direct internet access for the subnet my application gateway was deployed to.
# https://github.com/hashicorp/terraform-provider-azurerm/issues/7889
# resource "azurerm_route_table" "appcore_agw" {
#   name                = local.agw_route_table_name
#   location            = azurerm_resource_group.appcore_rg.location
#   resource_group_name = azurerm_resource_group.appcore_rg.name
#   route {
#     name                   = local.user_defined_route_name
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "Internet"
#   }
# }
# resource "azurerm_subnet_route_table_association" "appcore_agw" {
#   subnet_id      = azurerm_subnet.appcore_agw.id
#   route_table_id = azurerm_route_table.appcore_agw.id
#   depends_on = [
#     azurerm_subnet.appcore_agw,
#     azurerm_route_table.appcore_agw,
#   ]
# }
##################################################################################################################################


resource "azurerm_public_ip" "appcore_agw" {
  name                = "pip-agw-${var.Enterprise_product}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  # agw-appcore-myclient-dev with SKU Standard_v2 can only reference public ip with Standard SKU
  # Static IP allocation must be used when creating Standard SKU public IP addresses
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}
