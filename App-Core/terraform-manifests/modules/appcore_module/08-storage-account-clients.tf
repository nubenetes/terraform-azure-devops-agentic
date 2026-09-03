# https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
# Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
# Your storage account name must be unique within Azure. No two storage accounts can have the same name.

# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/storage/storage-container/main.tf

# https://www.hashicorp.com/blog/terraform-azurerm-3-0-brings-enhanced-azure-function-support
# The field allow_blob_public_access has been renamed to allow_nested_items_to_be_public to resolve confusion about what this field does.
# This field specifies whether items within the Storage Account (such as Containers and Blobs) can opt-in to being made public
# (for example at the Container or Blob level) — and not that all resources within this Storage Account are public by default.


resource "azurerm_storage_container" "appcore_myclient" {
  for_each             = toset(var.client_names)
  name                 = "co-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  storage_account_name = azurerm_storage_account.appcore.name
  #container_access_type = "private"
  container_access_type = "blob"
}


##################
# EULA files
##################
resource "azurerm_storage_blob" "EULA-PILOT-en-GB" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PILOT-en-GB.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PILOT-en-GB.pdf"
}
resource "azurerm_storage_blob" "EULA-PILOT-es-ES" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PILOT-es-ES.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PILOT-es-ES.pdf"
}
resource "azurerm_storage_blob" "app-analysis-service-PROD-es-ES" {
  for_each               = toset(var.client_names)
  name                   = "app-analysis-service-PROD-es-ES.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/app-analysis-service-PROD-es-ES.pdf"
}
resource "azurerm_storage_blob" "app-analysis-service-PROD-en-US" {
  for_each               = toset(var.client_names)
  name                   = "app-analysis-service-PROD-en-US.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/app-analysis-service-PROD-en-US.pdf"
}
resource "azurerm_storage_blob" "app-analysis-service-PILOT-en-US" {
  for_each               = toset(var.client_names)
  name                   = "app-analysis-service-PILOT-en-US.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/app-analysis-service-PILOT-en-US.pdf"
}
resource "azurerm_storage_blob" "EULA-PROD-es-ES" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PROD-es-ES.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PROD-es-ES.pdf"
}
resource "azurerm_storage_blob" "EULA-PROD-en-US" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PROD-en-US.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PROD-en-US.pdf"
}
resource "azurerm_storage_blob" "EULA-PROD-en-GB" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PROD-en-GB.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PROD-en-GB.pdf"
}
resource "azurerm_storage_blob" "EULA-PILOT-en-US" {
  for_each               = toset(var.client_names)
  name                   = "EULA-PILOT-en-US.pdf"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore_myclient[each.key].name
  type                   = "Block"
  source                 = "azure_blobs/EULA-PILOT-en-US.pdf"
}

##################
# App-Link
##################
resource "azurerm_storage_container" "applink_onprem_myclient" {
  for_each              = toset(var.client_names)
  name                  = "co-applink-onprem-${each.value}-${local.instance_environment}"
  storage_account_name  = azurerm_storage_account.appcore.name
  container_access_type = "blob"
}