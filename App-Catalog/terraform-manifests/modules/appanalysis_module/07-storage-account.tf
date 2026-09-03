# https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
# Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
# Your storage account name must be unique within Azure. No two storage accounts can have the same name.

resource "azurerm_storage_account" "sa_appanalysis" {
  for_each                 = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                     = "${var.storage_prefix}${each.value}${local.instance_environment}"
  account_replication_type = var.storage_account_replication_type #"RAGRS"
  account_tier             = var.storage_account_tier             #"Standard"
  location                 = local.location
  resource_group_name      = azurerm_resource_group.App-Catalog_rg[each.key].name
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )
  share_properties {
    cors_rule {
      allowed_origins    = ["https://${each.value}.${local.dns_zone}", ]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_headers    = ["*", ]
      exposed_headers    = ["*", ]
      max_age_in_seconds = "1800"
    }

  }
}
