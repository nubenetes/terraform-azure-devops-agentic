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
