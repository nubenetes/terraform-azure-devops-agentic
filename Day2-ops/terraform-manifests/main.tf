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

data "azuread_service_principal" "aks_aad_server" {
  display_name = "Azure Kubernetes Service AAD Server"
}

##########################################
# AzureAD
##########################################
data "azuread_client_config" "current" {}

module "europe_day2_ops" {
  source = "./modules/day2_ops_module"
  count  = local.deploy_Europe ? 1 : 0
  providers = {
    azurerm             = azurerm.europe
    helm                = helm.europe
    kubectl             = kubectl.europe
    kubernetes          = kubernetes.europe
    azurerm.manualinfra = azurerm.manualinfra
    ansible             = ansible.europe
  }
  location_code = var.location_code_europe
  environment   = var.environment
  gitbranch     = var.gitbranch
}

module "us_day2_ops" {
  source = "./modules/day2_ops_module"
  count  = local.deploy_United_States ? 1 : 0
  providers = {
    azurerm             = azurerm.us
    helm                = helm.us
    kubectl             = kubectl.us
    kubernetes          = kubernetes.us
    azurerm.manualinfra = azurerm.manualinfra
    ansible             = ansible.us
  }
  location_code = var.location_code_unitedstates
  environment   = var.environment
  gitbranch     = var.gitbranch
}
