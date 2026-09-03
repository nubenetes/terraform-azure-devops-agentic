locals {
  tags = {
    Project     = "GitOps Azure DevOps Terraform"
    Product     = "${var.Enterprise_product}"
    Environment = "${local.gitbranch}${var.environment}"
    Department  = "R&D"
    Team        = "System Architecture and Cloud Operations"
    CostCentre  = "C1234" # Example
  }
  gitbranch      = (var.gitbranch != "main") ? "d" : "" # d = develop branch , "" = main branch
  dns_child_zone = "${local.gitbranch}${var.dns_child_zone}"
  dns_zone       = "${local.dns_child_zone}.${var.dns_parent_zone}"
}