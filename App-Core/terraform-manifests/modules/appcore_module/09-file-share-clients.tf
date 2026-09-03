# https://docs.microsoft.com/en-us/answers/questions/719175/destroy-or-modification-to-azure-storage-account-f.html

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
# The storage share supports two storage tiers: premium and standard. Standard file shares are created in general purpose (GPv1 or GPv2) storage accounts
# and premium file shares are created in FileStorage storage accounts.
# For further information, refer to the section "What storage tiers are supported in Azure Files?" of documentation.

resource "azurerm_storage_share" "fs_client" {
  for_each             = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                 = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  storage_account_name = azurerm_storage_account.appcore.name
  quota                = 5120
  # (Required) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be 1GB (or higher) and at most 5120 GB (5 TB).
  # For Premium FileStorage storage accounts, this must be greater than 100 GB and at most 102400 GB (100 TB).
  access_tier = "TransactionOptimized"
  depends_on = [
    azurerm_storage_account.appcore,
  ]
}
