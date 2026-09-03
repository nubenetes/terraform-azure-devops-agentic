# Since these variables are re-used - a locals block makes this more maintainable
locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}" #"appanalysis"
    Environment = "${var.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch                    = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  location                     = lower("${var.location}")
  instance_environment         = "${local.gitbranch}${var.location_code}${var.environment}"
  instance_name                = "${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name          = "${var.rg_prefix}-${local.instance_name}"
  dns_zone                     = "${var.dns_child_zone}.${var.dns_parent_zone}"
  sharedinfra_environment      = (var.environment != "pro" && var.environment != "dem") ? "eng" : "pro" # PRO & DEM (demo) environments are considered PRODUCTION
  sharedinfra_environment2     = (var.gitbranch != "main") ? "deng" : "${local.sharedinfra_environment}"
  dns_zone_resource_group_name = "${var.rg_prefix}-sharedinfra-dns-${local.sharedinfra_environment2}"
  # Dynamic Environment Generator:
  # Used by dns names attached to apps (which lack of "prod" term when running in production)
  # Used by Azure Storage Account & Azure Key Vaults due to length constraints.
  env_generator = (var.environment != "pro") ? var.environment : ""

  # Enterprise Monitor Client (Prometheus exporter): Our Prometheus is setup as Push-Based Metrics System
  # Legacy: https://pushgateway-app-analysis.enterprise.com
  push_gateway_prometheus_metrics = "${local.gitbranch}${local.env_generator}${var.Enterprise_product}-pushgateway.${local.dns_zone}"

  # Mongodb
  mongodb_databases = [for e in var.client_names : "modb-${var.Enterprise_product}-${e}"]

  # List of login pages (one per client)
  list_of_login_pages = tolist([for e in var.client_names : "https://${e}-${var.dns_prefix}${local.gitbranch}${local.env_generator}.${local.dns_zone}/login"])
  k8s_namespace_name  = "appanalysis${local.gitbranch}${var.location_code}${local.env_generator}"
}
