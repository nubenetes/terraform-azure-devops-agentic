# https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
# Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
# Your storage account name must be unique within Azure. No two storage accounts can have the same name.

# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/storage/storage-container/main.tf

# https://www.hashicorp.com/blog/terraform-azurerm-3-0-brings-enhanced-azure-function-support
# The field allow_blob_public_access has been renamed to allow_nested_items_to_be_public to resolve confusion about what this field does.
# This field specifies whether items within the Storage Account (such as Containers and Blobs) can opt-in to being made public
# (for example at the Container or Blob level) — and not that all resources within this Storage Account are public by default.

resource "azurerm_storage_account" "appcore" {
  name                     = local.storage_account_name
  location                 = local.location
  resource_group_name      = azurerm_resource_group.appcore_rg.name
  account_replication_type = var.storage_account_replication_type #"RAGRS" #"LRS"
  account_tier             = var.storage_account_tier             #"Standard"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  access_tier              = "Hot"
  #allow_nested_items_to_be_public = true
  public_network_access_enabled = true # (Optional) Whether the public network access is enabled? Defaults to true.
  tags                          = local.tags
  share_properties {
    cors_rule {
      allowed_origins = ["*"] # Not secure, origins are each customer addr  (Required) A list of origin domains that will be allowed by CORS.
      allowed_methods = [
        "GET",
        "HEAD",
        "POST",
        "PUT",
      ]
      allowed_headers    = ["*"] # (Required) A list of response headers that are exposed to CORS clients.
      exposed_headers    = ["*"] # (Required) A list of response headers that are exposed to CORS clients.
      max_age_in_seconds = 1800  # (Required) The number of seconds the client should cache a preflight response.
    }
  }
  depends_on = [
    azurerm_resource_group.appcore_rg,
  ]
}
resource "azurerm_storage_container" "appcore" {
  name                 = "co-${var.Enterprise_product}-${local.instance_environment}"
  storage_account_name = azurerm_storage_account.appcore.name
  #container_access_type = "private"
  container_access_type = "blob"
}

################################################################
# Angular Configuration JSON File - appcore_front_spa
################################################################
resource "azurerm_storage_blob" "appcore_front_angular_settings" {
  name                   = "appcore-front-angular-public-shared-config.json"
  storage_account_name   = azurerm_storage_account.appcore.name
  storage_container_name = azurerm_storage_container.appcore.name
  type                   = "Block"
  content_type           = "text/plain"
  source_content         = data.template_file.template_appcore_front_angular_settings.rendered
}

################################################################
# Angular Configuration JSON File - app-analysis_viewer_front_spa
################################################################
# resource "azurerm_storage_blob" "app-analysis_front_angular_settings" {
#   for_each               = toset(var.client_names)
#   name                   = "app-analysis-front-angular-public-shared-config-${each.value}.json"
#   storage_account_name   = azurerm_storage_account.appcore.name
#   storage_container_name = azurerm_storage_container.appcore.name
#   type                   = "Block"
#   content_type           = "text/plain"
#   source_content         = "${data.template_file.template_app-analysis_front_angular_settings[each.value].rendered}"
# }


# Tips: Best Practices for The Other Azure Storage Resources
# https://shisho.dev/dojo/providers/azurerm/Storage/azurerm-storage-blob/
# https://shisho.dev/dojo/providers/azurerm/Storage/azurerm-storage-account/
# https://shisho.dev/dojo/providers/azurerm/Storage/azurerm-storage-account-network-rules/
# In addition to the azurerm_storage_account, Azure Storage has the other resources that should be configured for security reasons.
# Please check some examples of those resources and precautions.
#
# azurerm_storage_account - Ensure to use HTTPS connections
# azurerm_storage_account_network_rules - Ensure to allow Trusted Microsoft Services to bypass
#
# It is better to allow Trusted Microsoft Services to bypass. They are not able to access storage account unless rules are set to allow them explicitly.

# resource "azurerm_storage_account_network_rules" "appcore" {
#   storage_account_id         = azurerm_storage_account.appcore.id
#   default_action             = "Allow" #"Deny" #"Allow"  # (Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow.
#   #ip_rules                   = ["127.0.0.1"]  # (Optional) List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed.
#   #virtual_network_subnet_ids = [azurerm_subnet.example.id] # (Optional) A list of virtual network subnet ids to to secure the storage account.
#   bypass                     = ["AzureServices"] # (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None.
# }


################################################################
# Angular Configuration JSON File - appcore_front_spa
################################################################
# resource "azurerm_storage_blob" "appcore_log_analytics_workspace_settings" {
#   name                   = "list-log-analytics-workspaces.json"
#   storage_account_name   = azurerm_storage_account.appcore.name
#   storage_container_name = azurerm_storage_container.appcore.name
#   type                   = "Block"
#   content_type           = "text/plain"
#   source_content         = "${data.template_file.template_appcore_front_angular_settings.rendered}"
# }


########################################################
# Storage Queue for each test user on Enterprise center
########################################################
# resource "azurerm_storage_queue" "testuser1" {
#   name                 = testuser1-Enterprise # testuser1-appcore-client-anon-client-anon
#   resource_group_name  = azurerm_resource_group.appcore_rg.name
#   storage_account_name = azurerm_storage_account.appcore.name
# }