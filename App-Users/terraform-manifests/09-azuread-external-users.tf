##################################################################################
# AzureAD B2B external user (guest) invitations
# User Principal Names (UPN) in the format prefix#EXT#@yourtenant.onmicrosoft.com
# https://rafaelmedeiros94.medium.com/terraform-retrieving-values-from-yaml-files-ffd72b043eae
# https://learn.microsoft.com/en-us/azure/active-directory/external-identities/faq
##################################################################################

# terraform map variable: https://gist.github.com/devops-school/1f3efed15d390748b208a109f9765e0c

resource "azuread_invitation" "external" {
  for_each = {
    for email in distinct([for u in local.load_yaml_external_users : u.email]) :
    email => [for u in local.load_yaml_external_users : u if u.email == email][0]
  }
  user_email_address = each.value.email
  redirect_url       = "https://appc${each.value.env}.${var.dns_zone_per_env["${each.value.env}"]}.enterprise.com/login"
  user_type          = "Guest"
  message {
    language              = "en-US"
    additional_recipients = ["cloud-admin@example.com"] # (Optional) Email addresses of additional recipients the invitation message should be sent to. Only 1 additional recipient is currently supported by Azure.
  }
}

