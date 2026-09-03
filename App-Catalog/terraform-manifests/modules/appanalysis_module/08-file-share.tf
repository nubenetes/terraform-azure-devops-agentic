# https://docs.microsoft.com/en-us/answers/questions/719175/destroy-or-modification-to-azure-storage-account-f.html

resource "azurerm_storage_share" "fs_appanalysis" {
  for_each             = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                 = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  storage_account_name = azurerm_storage_account.sa_appanalysis[each.key].name
  quota                = 1
  access_tier          = "TransactionOptimized"
}
