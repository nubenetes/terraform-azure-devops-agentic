# Since these variables are re-used - a locals block makes this more maintainable
locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch                      = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  location                       = lower("${var.location}")
  resource_group_name            = "${var.rg_prefix}-${var.Enterprise_product}-${local.gitbranch}${var.environment}"
  dns_child_zone                 = "${local.gitbranch}${var.dns_child_zone}"
  dns_zone                       = "${local.dns_child_zone}.${var.dns_parent_zone}"
  environment                    = "${local.gitbranch}${var.environment}"
  environment_with_location_code = "${local.gitbranch}${var.location_code}${var.environment}"
  aks_cluster_name               = "aks-${local.environment_with_location_code}"

  #######################################################################################################################
  # Create a list of users per client with nested loops in terraform
  # Nested for_each/loops in terraform: https://www.daveperrett.com/articles/2000/01/01/nested-for-each-with-terraform/ 
  #######################################################################################################################
  # client_names                                   = var.client_names
  # user_names                                     = var.user_names
  # # Nested loop over both lists, and flatten the result.
  # list_of_clients_users = distinct(flatten([
  #   for client in local.client_names : [
  #     for user in local.user_names : {
  #       user    = user
  #       client  = client
  #     }
  #   ]
  # ]))

}

