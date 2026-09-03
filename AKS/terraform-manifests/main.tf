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

module "europe_aks" {
  source = "./modules/sharedinfra_aks_module"
  count  = local.deploy_Europe ? 1 : 0
  # Feature Flag on Terraform
  # If 'true', provision 1 of this resource
  # If 'false', don't provision this
  providers = {
    azurerm             = azurerm.europe
    azurerm.manualinfra = azurerm.manualinfra
  }
  # Defined in variables.tf :
  # vpc_cidr                                                                       = "10.1.0.0/16" # example
  location           = var.location_europe
  environment        = var.environment
  gitbranch          = var.gitbranch
  ssh_public_key     = var.ssh_public_key
  location_code      = var.location_code_europe # ne
  rg_prefix          = var.rg_prefix
  Enterprise_product = "${var.Enterprise_product}-aks"
  #acr_name                                                                        = var.acr_name_europe   # ACR deployed with terraform is currently disabled
  kubernetes_version = var.kubernetes_version
  #dns_zone_id                                                                     = module.dns.0.dns_zone_id
  aks_administrators                                 = var.aks_administrators
  aks_developers                                     = var.aks_developers
  service_principals_with_aad_aks_cluster_admin_role = var.service_principals_with_aad_aks_cluster_admin_role
  dns_parent_zone                                    = var.dns_parent_zone
  dns_child_zone                                     = (var.environment != "pro") ? "${var.dns_child_zone_eng}" : "${var.dns_child_zone_pro}"
}


module "us_aks" {
  source = "./modules/sharedinfra_aks_module"
  count  = local.deploy_United_States ? 1 : 0
  # Feature Flag on Terraform
  # If 'true', provision 1 of this resource
  # If 'false', don't provision this
  providers = {
    azurerm             = azurerm.us
    azurerm.manualinfra = azurerm.manualinfra
  }
  # Defined in variables.tf :
  # vpc_cidr                                                                       = "10.1.0.0/16" # example
  location           = var.location_unitedstates
  environment        = var.environment
  gitbranch          = var.gitbranch
  ssh_public_key     = var.ssh_public_key
  location_code      = var.location_code_unitedstates # cus
  rg_prefix          = var.rg_prefix
  Enterprise_product = "${var.Enterprise_product}-aks"
  #acr_name                                                                        = var.acr_name_unitedstates  # ACR deployed with terraform is currently disabled
  kubernetes_version = var.kubernetes_version
  #dns_zone_id                                                                     = module.dns.0.dns_zone_id
  aks_administrators                                 = var.aks_administrators
  aks_developers                                     = var.aks_developers
  service_principals_with_aad_aks_cluster_admin_role = var.service_principals_with_aad_aks_cluster_admin_role
  dns_parent_zone                                    = var.dns_parent_zone
  dns_child_zone                                     = (var.environment != "pro") ? "${var.dns_child_zone_eng}" : "${var.dns_child_zone_pro}"
}
