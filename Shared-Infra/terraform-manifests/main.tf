# Terraform - Deploy to Multiple Regions Using Providers https://www.youtube.com/watch?v=9f-NrYZ5tQg

# Terraform Modules - The Root Module and Child Modules:
# https://www.terraform.io/language/modules
# https://www.terraform.io/language/modules/syntax
# https://jeffbrown.tech/terraform-module-output/

# Feature Flags on Terraform
# Deploy conditionally based on Feature Flag variable - https://build5nines.com/terraform-if-else-conditional-resource-and-module-deployment/
# https://build5nines.com/terraform-feature-flags-environment-toggle-design-patterns/
# But wait, outputs are different!! https://dev.to/circa10a/how-to-use-feature-toggles-with-terraform-28fi
#     https://github.com/circa10a/terraform-feature-toggle-example


module "dns" {
  source = "./modules/sharedinfra_dns_module"
  count  = 1
  providers = {
    # https://developer.hashicorp.com/terraform/language/meta-arguments/module-providers
    azurerm = azurerm.europe
  }
  # Defined in variables.tf :
  # vpc_cidr                                                                       = "10.1.0.0/16" # example
  # vnet_cidr                                                                       = var.vnet_cidr
  location           = var.location_europe # "northeurope"
  rg_prefix          = var.rg_prefix
  environment        = var.environment # 'eng' or 'pro'
  gitbranch          = var.gitbranch
  aad_tenant_id      = var.aad_tenant_id
  subnet_cidr        = var.subnet_cidr
  dns_parent_zone    = var.dns_parent_zone
  dns_child_zone     = (var.environment != "pro") ? "${var.dns_child_zone_eng}" : "${var.dns_child_zone_pro}"
  dns_prefix         = var.dns_prefix
  Enterprise_product = "${var.Enterprise_product}-dns"
}

module "dns_top_level_domain" {
  source = "./modules/dns_top_level_domain_module"
  providers = {
    azurerm = azurerm.manualinfra
  }
  Enterprise_product    = var.Enterprise_product
  gitbranch             = var.gitbranch
  dns_parent_zone       = var.dns_parent_zone
  dns_child_zone        = (var.environment != "pro") ? "${var.dns_child_zone_eng}" : "${var.dns_child_zone_pro}"
  dns_zone_name_servers = module.dns.0.dns_zone_name_servers
  environment           = var.environment # 'eng' or 'pro'
  depends_on = [
    module.dns,
  ]
}


module "sharedinfra_microsoft_defender_cloud" {
  source = "./modules/sharedinfra_microsoft_defender_cloud"
  providers = {
    azurerm = azurerm.europe
  }
  Enterprise_product = "sharedinfra-mdc"
  gitbranch          = var.gitbranch
  environment        = var.environment # 'eng' or 'pro'
}
