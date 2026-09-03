################################################################################################################################
# Create Outputs
# https://www.terraform.io/language/values/outputs
# https://jeffbrown.tech/terraform-module-output/
# https://stackoverflow.com/questions/64828445/can-i-automatically-see-all-child-modules-output-variables-without-re-defining
# https://stackoverflow.com/questions/70607001/module-db-is-a-list-of-object-known-only-after-apply
# https://www.reddit.com/r/Terraform/comments/pbx04m/conditional_expression_with_dependency/
# https://www.terraform.io/language/meta-arguments/count
# https://stackoverflow.com/questions/73461915/use-terraform-module-output-with-other-child-module-when-output-is-tuple
#
# Terraform Feature Flags:
# But wait, outputs are different!! https://dev.to/circa10a/how-to-use-feature-toggles-with-terraform-28fi
################################################################################################################################


####################################
# Regions Deployed
####################################
output "deploy_Europe" {
  value = local.deploy_Europe
}
output "deploy_United_States" {
  value = local.deploy_United_States
}

####################################
# AKS Module
# data.azurerm_client_config
####################################
output "myAzureSubscriptionAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.myAzureSubscription : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "myAzureTenantIdAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.myAzureTenantId : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "myAzureSubscriptionAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.myAzureSubscription : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "myAzureTenantIdAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.myAzureTenantId : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}

############################################
# AKS Module - Europe
# Outputs of modules/sharedinfra_aks_module
############################################
# Resource Group Outputs
output "aks_locationAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.location : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_resource_group_idAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.resource_group_id : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_resource_group_nameAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.resource_group_name : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
# Azure AKS Versions Datasource
output "aks_versionsAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.versions : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_latest_versionAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.latest_version : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_nameAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.name : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_network_profileAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.network_profile : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
# Azure AD Group Object Id
output "aks_azure_ad_group_administrators_nameAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_administrators_name : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_azure_ad_group_administrators_idAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_administrators_id : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_azure_ad_group_administrators_objectidAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_administrators_objectid : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_azure_ad_group_developers_nameAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_developers_name : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_azure_ad_group_developers_idAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_developers_id : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_azure_ad_group_developers_objectidAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.azure_ad_group_developers_objectid : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}

# Azure AKS Outputs
output "aks_cluster_idAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.aks_cluster_id : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_cluster_nameAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.aks_cluster_name : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}
output "aks_cluster_kubernetes_versionAKSEurope" {
  value = local.deploy_Europe ? module.europe_aks.0.aks_cluster_kubernetes_version : null # Feature Flag on Terraform
  depends_on = [
    module.europe_aks,
  ]
}

############################################
# AKS Module - United States
# Outputs of modules/sharedinfra_aks_module
############################################
# Resource Group Outputs
output "aks_locationAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.location : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_resource_group_idAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.resource_group_id : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_resource_group_nameAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.resource_group_name : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
# Azure AKS Versions Datasource
output "aks_versionsAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.versions : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_latest_versionAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.latest_version : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_nameAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.name : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_network_profileAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.network_profile : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
# Azure AD Group Object Id
output "aks_azure_ad_group_administrators_nameUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_administrators_name : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_azure_ad_group_administrators_idUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_administrators_id : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_azure_ad_group_administrators_objectidUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_administrators_objectid : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_azure_ad_group_developers_nameUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_developers_name : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_azure_ad_group_developers_idUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_developers_id : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_azure_ad_group_developers_objectidUS" {
  value = local.deploy_United_States ? module.us_aks.0.azure_ad_group_developers_objectid : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}

# Azure AKS Outputs
output "aks_cluster_idAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.aks_cluster_id : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_cluster_nameAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.aks_cluster_name : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
output "aks_cluster_kubernetes_versionAKSUS" {
  value = local.deploy_United_States ? module.us_aks.0.aks_cluster_kubernetes_version : null # Feature Flag on Terraform
  depends_on = [
    module.us_aks,
  ]
}
