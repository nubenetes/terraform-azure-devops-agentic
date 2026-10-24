##########################################################################################################################################
# Microsoft Defender
# https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/deploy-microsoft-defender-for-cloud-via-terraform/ba-p/3563710
##########################################################################################################################################

####################################################################
# Enabling the default Azure Security Benchmark Policy initiative
####################################################################

data "azurerm_policy_set_definition" "cis_benchmark" {
  display_name = "Microsoft cloud security benchmark"
}

resource "azurerm_subscription_policy_assignment" "asb_assignment" {
  name                 = "azuresecuritybenchmark"
  display_name         = "Azure Security Benchmark"
  policy_definition_id = data.azurerm_policy_set_definition.cis_benchmark.id
  subscription_id      = data.azurerm_subscription.current.id
}

#########################
# Enabling MDC Plans
#########################

resource "azurerm_security_center_subscription_pricing" "mdc_arm" {
  #tier          = "Standard"
  tier          = "Free"
  resource_type = "Arm"
  subplan       = "PerTransaction"
}

resource "azurerm_security_center_subscription_pricing" "mdc_appservices" {
  #tier          = "Standard"
  tier          = "Free"
  resource_type = "AppServices"
}

removed {
  from = azurerm_security_center_subscription_pricing.mdc_containerregistry
  lifecycle {
    destroy = false
  }
}

resource "azurerm_security_center_subscription_pricing" "mdc_keyvaults" {
  #tier          = "Standard"
  tier          = "Free"
  resource_type = "KeyVaults"
  subplan       = "PerKeyVault"
}

resource "azurerm_security_center_subscription_pricing" "mdc_storageaccounts" {
  #tier          = "Standard"
  tier          = "Free"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}

resource "azurerm_security_center_subscription_pricing" "mdc_containers" {
  #tier          = "Standard"
  tier          = "Free"
  resource_type = "Containers"
}

############################################
# Enabling integrations with MDE and MDCA
############################################

resource "azurerm_security_center_setting" "setting_mcas" {
  setting_name = "MCAS"
  enabled      = false
}

resource "azurerm_security_center_setting" "setting_mde" {
  setting_name = "WDATP"
  enabled      = true
}

################################
# Setting up security contacts
################################

resource "azurerm_security_center_contact" "mdc_contact" {
  name                = "default"
  email               = "cloud-admin@example.com"
  phone               = "+34620898686"
  alert_notifications = true
  alerts_to_admins    = true
}

###################################################
# Enabling Log Analytics agent auto-provisioning
###################################################

removed {
  from = azurerm_security_center_auto_provisioning.auto-provisioning
  lifecycle {
    destroy = false
  }
}


#########################################################
# Enabling Vulnerability Assessment auto-provisioning
#########################################################

resource "azurerm_subscription_policy_assignment" "va-auto-provisioning" {
  name                 = "mdc-va-autoprovisioning"
  display_name         = "Configure machines to receive a vulnerability assessment provider"
  policy_definition_id = data.azurerm_policy_set_definition.cis_benchmark.id
  subscription_id      = data.azurerm_subscription.current.id
  identity {
    type = "SystemAssigned"
  }
  #location = "North Europe"
  location   = azurerm_resource_group.sharedinfra_mdc_rg.location
  parameters = <<PARAMS
{ "vaType": { "value": "mdeTvm" } }
PARAMS
}

resource "azurerm_role_assignment" "va-auto-provisioning-identity-role" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Security Admin"
  principal_id         = azurerm_subscription_policy_assignment.va-auto-provisioning.identity[0].principal_id
}


############################################################
# create the Log Analytics workspace together with MDC
############################################################

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "mdc-security-workspace-${local.environment}"
  location            = azurerm_resource_group.sharedinfra_mdc_rg.location
  resource_group_name = azurerm_resource_group.sharedinfra_mdc_rg.name
  sku                 = "PerGB2018"
  tags                = local.tags
}

resource "azurerm_security_center_workspace" "la_workspace" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.la_workspace.id
}

# ###########################################
# # Configuring Continuous Export settings
# ###########################################

resource "azurerm_security_center_automation" "la-exports" {
  name                = "ExportToWorkspace"
  location            = azurerm_resource_group.sharedinfra_mdc_rg.location
  resource_group_name = azurerm_resource_group.sharedinfra_mdc_rg.name
  tags                = local.tags

  action {
    type        = "loganalytics"
    resource_id = azurerm_log_analytics_workspace.la_workspace.id
  }

  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
    }
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Medium"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  scopes = [data.azurerm_subscription.current.id]
}
