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


######################################
# Resource Group - DNS Global Service
######################################
output "myResourceGroupDNS" {
  value = module.dns.0.myResourceGroup
  depends_on = [
    # https://www.terraform.io/language/values/outputs#depends_on-explicit-output-dependencies
    # when a parent module accesses an output value exported by one of its child modules, the dependencies of that output value allow Terraform to correctly determine
    # the dependencies between resources defined in different modules.
    module.dns,
  ]
}

###########################################
# DNS module - data.azurerm_client_config
###########################################
output "myAzureSubscriptionDNS" {
  value = module.dns.0.myAzureSubscription
  depends_on = [
    module.dns,
  ]
}
output "myAzureTenantIdDNS" {
  value = module.dns.0.myAzureTenantId
  depends_on = [
    module.dns,
  ]
}

####################################
# DNS Module - DNS Zone
####################################
output "dns_zone" {
  value = module.dns.0.dns_zone
  depends_on = [
    module.dns,
  ]
}

#########################################
# DNS Module - data.azurerm_subscription
#########################################
output "myAzureSubscription_idDNS" {
  value = module.dns.0.myAzureSubscription_id
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_display_nameDNS" {
  value = module.dns.0.myAzureSubscription_display_name
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_tenant_idDNS" {
  value = module.dns.0.myAzureSubscription_tenant_id
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_stateDNS" {
  value = module.dns.0.myAzureSubscription_state
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_location_placement_idDNS" {
  value = module.dns.0.myAzureSubscription_location_placement_id
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_quota_idDNS" {
  value = module.dns.0.myAzureSubscription_quota_id
  depends_on = [
    module.dns,
  ]
}
output "myAzureSubscription_spending_limitDNS" {
  value = module.dns.0.myAzureSubscription_spending_limit
  depends_on = [
    module.dns,
  ]
}

#############################
# DNS Module - gitbranch
#############################
output "gitbranchDNS" {
  value = module.dns.0.gitbranch
  depends_on = [
    module.dns,
  ]
}
