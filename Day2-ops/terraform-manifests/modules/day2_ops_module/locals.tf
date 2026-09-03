locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.environment_with_location_code}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  #location                             = lower("${var.location}")
  #resource_group_name                  = "${var.rg_prefix}-${var.Enterprise_product}-${local.gitbranch}${var.location_code}${var.environment}"
  environment                           = "${local.gitbranch}${var.environment}"
  dns_child_zone                        = (var.environment != "pro") ? "${local.gitbranch}eng" : "${local.gitbranch}apps"
  environment_with_location_code        = "${local.gitbranch}${var.location_code}${var.environment}"
  appr_name_kubeapps_login              = "appr-aks-kubeapps-${local.environment_with_location_code}"
  appr_name_skooner_login               = "appr-aks-skooner-${local.environment_with_location_code}"
  appr_name_grafana_login               = "appr-aks-grafana-${local.environment_with_location_code}"
  appr_name_grafana_apps_login          = "appr-aks-grafana-${local.environment_with_location_code}"
  aad_group_aks_developers_name         = "AAD_AKS_Developers_${local.environment_with_location_code}"
  mylist_wildcard_certs                 = data.azurerm_key_vault_secrets.wildcards_Enterprise_com.names
  secret_name_in_akv_with_wildcard_cert = one([for item in local.mylist_wildcard_certs : item if can(regex("-${local.dns_child_zone}-", item))]) # https://stackoverflow.com/questions/71052674/get-item-contains-substring-terraform
  aks_cluster_name                      = "aks-${local.environment_with_location_code}"
  aks_resource_group_name               = "rg-sharedinfra-aks-${local.environment_with_location_code}"
  appr_name_prometheus_login            = "appr-aks-prometheus-${local.environment_with_location_code}"
}
