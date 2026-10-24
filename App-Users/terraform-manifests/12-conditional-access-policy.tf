# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/conditional_access_policy
# https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview
# https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-mfa-howitworks

resource "azuread_conditional_access_policy" "appcore_zero_trust_mfa" {
  count        = var.enable_conditional_access_policy ? 1 : 0
  display_name = "cap-${var.Enterprise_product}-${local.gitbranch}${var.environment}-zero-trust-mfa"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = distinct(concat(
        [for g in data.azuread_group.appcore_admin_role_internal_users : g.object_id],
        [for g in data.azuread_group.appcore_user_role_internal_users : g.object_id],
        [for g in data.azuread_group.app-analysis_admin : g.object_id],
        [for g in data.azuread_group.app-analysis_users : g.object_id],
        [for g in data.azuread_group.external_users : g.object_id]
      ))
      excluded_users = [data.azuread_client_config.current.object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}
