# https://docs.microsoft.com/en-us/answers/questions/719175/destroy-or-modification-to-azure-storage-account-f.html

resource "azurerm_storage_share" "fs_appanalysis" {
  for_each           = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name               = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  storage_account_id = azurerm_storage_account.sa_appanalysis[each.key].id
  quota              = 1
  access_tier        = "TransactionOptimized"
}

resource "azurerm_recovery_services_vault" "vault_appanalysis" {
  for_each            = toset(var.client_names)
  name                = "rsv-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  location            = local.location
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  sku                 = "Standard"
  tags = merge(local.tags, {
    Client = "${each.key}"
  })
}

resource "azurerm_backup_policy_file_share" "policy_appanalysis" {
  for_each            = toset(var.client_names)
  name                = "bkp-policy-fs-${each.value}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  recovery_vault_name = azurerm_recovery_services_vault.vault_appanalysis[each.key].name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_container_storage_account" "protection_container_appanalysis" {
  for_each            = toset(var.client_names)
  resource_group_name = azurerm_resource_group.App-Catalog_rg[each.key].name
  recovery_vault_name = azurerm_recovery_services_vault.vault_appanalysis[each.key].name
  storage_account_id  = azurerm_storage_account.sa_appanalysis[each.key].id
}

resource "azurerm_backup_protected_file_share" "protected_fs_appanalysis" {
  for_each                  = toset(var.client_names)
  resource_group_name       = azurerm_resource_group.App-Catalog_rg[each.key].name
  recovery_vault_name       = azurerm_recovery_services_vault.vault_appanalysis[each.key].name
  source_storage_account_id = azurerm_backup_container_storage_account.protection_container_appanalysis[each.key].storage_account_id
  source_file_share_name    = azurerm_storage_share.fs_appanalysis[each.key].name
  backup_policy_id          = azurerm_backup_policy_file_share.policy_appanalysis[each.key].id
}

