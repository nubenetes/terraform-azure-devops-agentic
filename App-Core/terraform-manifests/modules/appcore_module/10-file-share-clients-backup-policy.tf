# https://learn.microsoft.com/en-us/azure/backup/backup-architecture
# https://learn.microsoft.com/en-us/azure/backup/backup-azure-files?tabs=backup-center

##############################################################################################################################################
# https://learn.microsoft.com/en-us/azure/backup/guidance-best-practices
# What workload type do you wish to protect? To design your vaults, ensure if you require a centralized/ decentralized mode of operation.
# What’s the required backup granularity ? Determine if it should be application consistent, crash consistent, or log backup.
# Do you’ve any compliance requirements? Ensure if you need to enforce security standards and separate access boundaries.
# What’s the required RPO, RTO? Determine the backup frequency and the speed of restore.
# Do you’ve any Data Residency constraints? Determine the storage redundancy for the required Data Durability.
# How long do you want to retain the backup data? Decide on the duration the backed-up data be retained in the storage.
#
# - Single or multiple vaults: Protect resources across multiple regions globally: If your organization has global operations across North America, Europe, and Asia,
# and your resources are deployed in East-US, UK West, and East Asia. One of the requirements of Azure Backup is that the vaults are
# required to be present in the same region as the resource to be backed-up. Therefore, you should create three separate vaults for each
# region to protect your resources.
# - Protect resources across various Business Units and Departments
# - Protect different workloads
# - Protect resources running in multiple environments: If your operations require you to work on multiple environments, such as production,
# non-production, and developer, then we recommend you create separate vaults for each.
##############################################################################################################################################

############################################################################################################################
# Azure Subscription - Resource Locks - AzureBackupProtectionLock
# Auto-created by Azure Backup for storage accounts registered with a Recovery Services Vault.
# This lock is intended to guard against deletion of backups due to accidental deletion of the storage account
############################################################################################################################

resource "azurerm_recovery_services_vault" "appcore" {
  name                = "recovery-vault-${var.Enterprise_product}-${local.instance_environment}"
  location            = azurerm_resource_group.appcore_rg.location
  resource_group_name = azurerm_resource_group.appcore_rg.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_file_share" "policy" {
  name                = "recovery-vault-policy-${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name = azurerm_resource_group.appcore_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.appcore.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = var.backup_policy_retention_daily #10
  }

  retention_weekly {
    count    = var.backup_policy_retention_weekly #7
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = var.backup_policy_retention_weekly #7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  # retention_yearly {
  #   count    = var.backup_policy_retention_yearly #7
  #   weekdays = ["Sunday"]
  #   weeks    = ["Last"]
  #   months   = ["January"]
  # }
}



resource "azurerm_backup_container_storage_account" "protection-container" {
  resource_group_name = azurerm_resource_group.appcore_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.appcore.name
  storage_account_id  = azurerm_storage_account.appcore.id
}

resource "azurerm_backup_protected_file_share" "fs_client" {
  for_each                  = toset(var.client_names)
  resource_group_name       = azurerm_resource_group.appcore_rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.appcore.name
  source_storage_account_id = azurerm_backup_container_storage_account.protection-container.storage_account_id
  source_file_share_name    = azurerm_storage_share.fs_client[each.key].name
  backup_policy_id          = azurerm_backup_policy_file_share.policy.id
}