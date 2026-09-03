

resource "azurerm_resource_group" "App-Catalog_rg" {
  for_each = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name     = "${var.rg_prefix}-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  location = local.location
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
}
