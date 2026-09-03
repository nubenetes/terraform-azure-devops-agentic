# Since these variables are re-used - a locals block makes this more maintainable
# https://stackoverflow.com/questions/71610535/dynamically-create-a-list-of-objects-to-be-used-inside-a-module-in-terraform

################################################################################
# Consuming and decoding JSON in Terraform:
# https://dev.to/lucassha/consuming-and-decoding-json-in-terraform-309p
################################################################################

locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.gitbranch}${var.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch                    = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  location                     = lower("${var.location}")
  instance_environment         = "sandbox-${local.gitbranch}${var.location_code}${var.environment}"
  instance_name                = "${var.Enterprise_product}-${local.instance_environment}"
  resource_group_name          = "${var.rg_prefix}-${local.instance_name}"
  dns_zone                     = "${var.dns_child_zone}.${var.dns_parent_zone}"
  sharedinfra_environment      = (var.environment != "pro" && var.environment != "dem" && var.environment != "res") ? "eng" : "pro" # PRO & DEM (demo) & RES (RESEARCH) environments are considered PRODUCTION
  sharedinfra_environment2     = (var.gitbranch != "main") ? "deng" : "${local.sharedinfra_environment}"
  dns_zone_resource_group_name = "${var.rg_prefix}-sharedinfra-dns-${local.sharedinfra_environment2}"
  env_generator                = (var.environment != "pro") ? var.environment : ""
  # App-Core DNS Name:
  appcore_dns_name = "${var.dns_prefix}${local.gitbranch}${var.dns_location_code}${local.env_generator}"
  appcore_fqdn     = "${local.appcore_dns_name}.${local.dns_zone}"
  # Storage Account:
  # Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
  # Your storage account name must be unique within Azure. No two storage accounts can have the same name.
  storage_account_name = "${var.storage_prefix}${local.gitbranch}${var.location_code}${local.env_generator}"
  k8s_namespace_name   = "appcore${local.gitbranch}${var.location_code}${local.env_generator}"

}
