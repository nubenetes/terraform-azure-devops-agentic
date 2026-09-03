# Since these variables are re-used - a locals block makes this more maintainable
# https://plainenglish.io/blog/terraform-yaml
# flatten ensures that this local value is a flat list of objects, rather than a list of lists of objects:
#   https://developer.hashicorp.com/terraform/language/functions/flatten

locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.gitbranch}-branch"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  ##########################################
  # Internal Users
  ##########################################
  yaml_filename_internal_users = (var.gitbranch != "main") ? "./20-internal-users-developbranch.yaml" : "./30-internal-users-mainbranch.yaml"
  load_yaml_internal_users     = yamldecode(file("${local.yaml_filename_internal_users}"))
  list_internal_users_with_custom_security_attributes = flatten([for user in local.load_yaml_internal_users :
    {
      "upn"    = "${user.email}"
      "center" = "${user.center}"
    }
  ])
  yaml_internal_users_without_roles = flatten([for user in local.load_yaml_internal_users :
    {
      "first-name" = lookup(user, "first-name", null)
      "last-name"  = lookup(user, "last-name", null)
      "department" = lookup(user, "department", null)
      "job-title"  = lookup(user, "job-title", null)
      "city"       = lookup(user, "city", null)
      "email"      = "${user.email}"
      "upn"        = "${user.email}"
      "center"     = "${user.center}"
      # appcore-admin-role            = lookup(user,"appcore-admin-role",null)
      # appcore-user-role             = lookup(user,"appcore-user-role",null)
      # app-analysis-admin-role       = lookup(user,"app-analysis-admin-role",null)
      # app-analysis-user-role        = lookup(user,"app-analysis-user-role",null)
    }
  ])
  yaml_internal_users = concat( # concat start
    flatten([                   # flatten 1 start
      for user_key, user in local.load_yaml_internal_users : [
        for appcore_admin_role_key, appcore_admin_role in lookup(user, "appcore-admin-role", []) : {
          "user-key"                  = user_key
          "first-name"                = lookup(user, "first-name", null)
          "last-name"                 = lookup(user, "last-name", null)
          "department"                = lookup(user, "department", null)
          "job-title"                 = lookup(user, "job-title", null)
          "city"                      = lookup(user, "city", null)
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${appcore_admin_role}.${var.dns_zone_per_env["${appcore_admin_role}"]}.enterprise.com/login"
          appcore-admin-role-key      = "${appcore_admin_role_key}.${appcore_admin_role}"
          appcore-admin-role          = "${appcore_admin_role}"
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 1 end
    ,
    flatten([ # flatten 2 start
      for user_key, user in local.load_yaml_internal_users : [
        for appcore_user_role_key, appcore_user_role in lookup(user, "appcore-user-role", []) : {
          "user-key"                  = user_key
          "first-name"                = lookup(user, "first-name", null)
          "last-name"                 = lookup(user, "last-name", null)
          "department"                = lookup(user, "department", null)
          "job-title"                 = lookup(user, "job-title", null)
          "city"                      = lookup(user, "city", null)
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${appcore_user_role}.${var.dns_zone_per_env["${appcore_user_role}"]}.enterprise.com/login"
          appcore-user-role-key       = "${appcore_user_role_key}.${appcore_user_role}"
          appcore-user-role           = "${appcore_user_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 2 end
    ,
    flatten([ # flatten 3 start
      for user_key, user in local.load_yaml_internal_users : [
        for app-analysis_admin_role_key, app-analysis_admin_role in lookup(user, "app-analysis-admin-role", []) : {
          "user-key"                  = user_key
          "first-name"                = lookup(user, "first-name", null)
          "last-name"                 = lookup(user, "last-name", null)
          "department"                = lookup(user, "department", null)
          "job-title"                 = lookup(user, "job-title", null)
          "city"                      = lookup(user, "city", null)
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${app-analysis_admin_role}.${var.dns_zone_per_env["${app-analysis_admin_role}"]}.enterprise.com/login"
          app-analysis-admin-role-key = "${app-analysis_admin_role_key}.${app-analysis_admin_role}"
          app-analysis-admin-role     = "${app-analysis_admin_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 3 end
    ,
    flatten([ # flatten 4 start
      for user_key, user in local.load_yaml_manually_provisioned_internal_users : [
        for app-analysis_user_role_key, app-analysis_user_role in lookup(user, "app-analysis-user-role", []) : {
          "user-key"                  = user_key
          "first-name"                = lookup(user, "first-name", null)
          "last-name"                 = lookup(user, "last-name", null)
          "department"                = lookup(user, "department", null)
          "job-title"                 = lookup(user, "job-title", null)
          "city"                      = lookup(user, "city", null)
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${app-analysis_user_role}.${var.dns_zone_per_env["${app-analysis_user_role}"]}.enterprise.com/login"
          app-analysis-user-role-key  = "${app-analysis_user_role_key}.${app-analysis_user_role}"
          app-analysis-user-role      = "${app-analysis_user_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
        }
      ]
    ]) # flatten 4 end
  )    # concat end

  #########################################################################
  # External Users - AzureAD B2B external Admin user (guest) invitations
  #########################################################################
  yaml_filename_external_users = (var.gitbranch != "main") ? "./40-external-users-developbranch.yaml" : "./50-external-users-mainbranch.yaml"
  load_yaml_external_users     = yamldecode(file("${local.yaml_filename_external_users}"))
  list_external_users_with_custom_security_attributes = flatten([for user in local.load_yaml_external_users :
    {
      "upn"    = join("#", [replace("${user.email}", "@", "_"), "EXT", "@enterprise.onmicrosoft.com"])
      "center" = "${user.center}"
    }
  ])
  yaml_external_users = flatten([for user_key, user in local.load_yaml_external_users :
    {
      "user-key" = user_key
      "email"    = "${user.email}"
      "upn"      = join("#", [replace("${user.email}", "@", "_"), "EXT", "@enterprise.onmicrosoft.com"])
      "center"   = "${user.center}"
      "env"      = "${user.env}"
      "role"     = "${user.role}"
    }
  ])

  ##########################################
  # Manually Provisioned Internal Users
  ##########################################
  yaml_filename_manually_provisioned_internal_users = (var.gitbranch != "main") ? "./60-internal-users-manually-provisioned-developbranch.yaml" : "./70-internal-users-manually-provisioned-mainbranch.yaml"
  load_yaml_manually_provisioned_internal_users     = yamldecode(file("${local.yaml_filename_manually_provisioned_internal_users}"))
  list_manually_provisioned_internal_users_with_custom_security_attributes = flatten([for user in local.load_yaml_manually_provisioned_internal_users :
    {
      "upn"    = "${user.email}"
      "center" = "${user.center}"
    }
  ])
  yaml_manually_provisioned_internal_users = concat( # concat start
    flatten([                                        # flatten 1 start
      for user_key, user in local.load_yaml_manually_provisioned_internal_users : [
        for appcore_admin_role_key, appcore_admin_role in lookup(user, "appcore-admin-role", []) : {
          "user-key"                  = user_key
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${appcore_admin_role}.${var.dns_zone_per_env["${appcore_admin_role}"]}.enterprise.com/login"
          appcore-admin-role-key      = "${appcore_admin_role_key}.${appcore_admin_role}"
          appcore-admin-role          = "${appcore_admin_role}"
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 1 end
    ,
    flatten([ # flatten 2 start
      for user_key, user in local.load_yaml_manually_provisioned_internal_users : [
        for appcore_user_role_key, appcore_user_role in lookup(user, "appcore-user-role", []) : {
          "user-key"                  = user_key
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${appcore_user_role}.${var.dns_zone_per_env["${appcore_user_role}"]}.enterprise.com/login"
          appcore-user-role-key       = "${appcore_user_role_key}.${appcore_user_role}"
          appcore-user-role           = "${appcore_user_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 2 end
    ,
    flatten([ # flatten 3 start
      for user_key, user in local.load_yaml_manually_provisioned_internal_users : [
        for app-analysis_admin_role_key, app-analysis_admin_role in lookup(user, "app-analysis-admin-role", []) : {
          "user-key"                  = user_key
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${app-analysis_admin_role}.${var.dns_zone_per_env["${app-analysis_admin_role}"]}.enterprise.com/login"
          app-analysis-admin-role-key = "${app-analysis_admin_role_key}.${app-analysis_admin_role}"
          app-analysis-admin-role     = "${app-analysis_admin_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-user-role      = null
          app-analysis-user-role-key  = null
        }
      ]
    ]) # flatten 3 end
    ,
    flatten([ # flatten 4 start
      for user_key, user in local.load_yaml_manually_provisioned_internal_users : [
        for app-analysis_user_role_key, app-analysis_user_role in lookup(user, "app-analysis-user-role", []) : {
          "user-key"                  = user_key
          "email"                     = "${user.email}"
          "center"                    = "${user.center}"
          "login"                     = "https://appc${app-analysis_user_role}.${var.dns_zone_per_env["${app-analysis_user_role}"]}.enterprise.com/login"
          app-analysis-user-role-key  = "${app-analysis_user_role_key}.${app-analysis_user_role}"
          app-analysis-user-role      = "${app-analysis_user_role}"
          appcore-admin-role          = null
          appcore-admin-role-key      = null
          appcore-user-role           = null
          appcore-user-role-key       = null
          app-analysis-admin-role     = null
          app-analysis-admin-role-key = null
        }
      ]
    ]) # flatten 4 end
  )    # concat end

}