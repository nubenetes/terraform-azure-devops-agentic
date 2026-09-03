locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch                     = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  environment                   = "${local.gitbranch}${var.location_code}${var.environment}"
  resource_group_name           = "${var.rg_prefix}-${var.Enterprise_product}-${local.environment}"
  aks_cluster_name              = "aks-${local.environment}"
  acr_name                      = local.environment # Azure Container Registry
  aad_group_aks_admins_name     = "AAD_AKS_Admins_${local.environment}"
  aad_group_aks_developers_name = "AAD_AKS_Developers_${local.environment}"
  # testing:
  dns_child_zone          = "${local.gitbranch}${var.dns_child_zone}"
  dns_zone                = "${local.dns_child_zone}.${var.dns_parent_zone}"
  dns_resource_group_name = "${var.rg_prefix}-sharedinfra-dns-${local.gitbranch}${var.environment}"
}