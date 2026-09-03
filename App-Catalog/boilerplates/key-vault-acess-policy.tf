# Boilerplate:
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/app-service-certificate/stored-in-keyvault/main.tf


resource "azurerm_key_vault" "appanalysis3_keyvault" {
  for_each                   = toset(var.client_names)                                          # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name                       = "kv-${var.Enterprise_product}-${each.value}${local.environment}" # "name" may only contain alphanumeric characters and dashes and must be between 3-24 char
  location                   = local.location
  resource_group_name        = azurerm_resource_group.appanalysis3_rg[each.key].name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  tags = merge(local.tags, {
    Client = "${each.key}"
    }
  )

  # App Gateway User Assigned Identity
  # https://docs.microsoft.com/en-us/azure/key-vault/general/assign-access-policy
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.appanalysis3_agw.principal_id

    key_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "Update",
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",
      "Purge",
      "Restore",
    ]
    certificate_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "GetIssuers",
      "DeleteIssuers",
      "Recover",
      "Restore",
      "Purge",
      "Update",
      "Import",
    ]
  }


  # Service Principal of azure devops pipeline:
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "Update",
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",
      "Purge",
      "Restore",
    ]
    certificate_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "GetIssuers",
      "DeleteIssuers",
      "Recover",
      "Restore",
      "Purge",
      "Update",
      "Import",
    ]
  }


  # Cloud Admin Permissions:
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "00000000-0000-0000-0000-000000000000" # Enterprise Architect
    key_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "Update",
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",
      "Purge",
      "Restore",
    ]
    certificate_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "GetIssuers",
      "DeleteIssuers",
      "Recover",
      "Restore",
      "Purge",
      "Update",
      "Import",
    ]
  }

  # # azurerm_app_service_certificate.myappcert
  #   access_policy {
  #     tenant_id = data.azurerm_client_config.current.tenant_id 
  #     object_id = azurerm_app_service_certificate.myappcert.id
  #     key_permissions = [
  #       "Get",
  #       "Create",
  #       "List",
  #       "Delete",
  #       "Update",
  #     ]
  #     secret_permissions = [
  #       "Get",
  #       "Set",
  #       "List",
  #       "Delete",
  #       "Recover",
  #       "Purge",
  #       "Restore",
  #     ]
  #     certificate_permissions = [
  #       "Get",
  #       "Create",
  #       "List",
  #       "Delete",
  #       "GetIssuers",
  #       "DeleteIssuers",
  #       "Recover",
  #       "Restore",
  #       "Purge",
  #       "Update",
  #       "Import",
  #     ]
  #   }

  #   # depends_on = [
  #   #   azurerm_resource_group.appanalysis3_rg,
  #   #   #azurerm_user_assigned_identity.appanalysis3_agw,
  #   # ]
}




#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate
# Generating a new certificate:
resource "azurerm_key_vault_certificate" "Enterprise_wildcard" {
  for_each     = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name         = "cert-${each.value}-${var.environment}"
  key_vault_id = azurerm_key_vault.appanalysis3_keyvault[each.key].id

  certificate {
    #contents = filebase64("certificate.pfx")
    contents = var.secret_appGatewayListenerSecure
    #password = "terraform"
    password = ""
  }

  certificate_policy {
    issuer_parameters {
      #name = "Self"
      name = "Unknown"
    }
    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
      #reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
    # lifetime_action {
    #   action {
    #     action_type = "AutoRenew"
    #   }

    #   trigger {
    #     days_before_expiry = 30
    #   }
    # }

    # x509_certificate_properties {
    #   # Server Authentication = 127.0.0.1.127.0.0.1.1
    #   # Client Authentication = 127.0.0.1.127.0.0.1.2
    #   extended_key_usage = ["127.0.0.1.127.0.0.1.1"]

    #   key_usage = [
    #     "cRLSign",
    #     "dataEncipherment",
    #     "digitalSignature",
    #     "keyAgreement",
    #     "keyCertSign",
    #     "keyEncipherment",
    #   ]

    #   subject_alternative_names {
    #     #dns_zones = ["${var.dns_zone}"]
    #     dns_zones = ["${var.client_name}.Enterprise${var.environment}.com"]
    #   }

    #   #subject            = "CN=${var.dns_zone}"
    #   subject            = "CN=${var.client_name}.Enterprise${var.environment}.com"
    #   validity_in_months = 12
    # }

  }
  # depends_on = [
  #   azurerm_key_vault.appanalysis3_keyvault,
  # ]
}

