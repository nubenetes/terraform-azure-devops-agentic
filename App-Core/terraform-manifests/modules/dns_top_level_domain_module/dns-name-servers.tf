##################################################################################################################################
# DNS NS Record on enterprise.com domain
# https://github.com/hashicorp/terraform-provider-azurerm/issues/2877
# https://www.terraform.io/language/meta-arguments/resource-provider
##################################################################################################################################

resource "azurerm_dns_ns_record" "my_env_subdomain_on_parent_domain" {
  name                = local.environment
  zone_name           = "enterprise.com"
  resource_group_name = "infrastructureresourcegroup"
  ttl                 = 300 # 5 min
  records             = var.dns_zone_name_servers
  tags = {
    Environment = "Production"
  }
}



