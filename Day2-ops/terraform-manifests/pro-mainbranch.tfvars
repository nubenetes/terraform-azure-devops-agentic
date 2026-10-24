# tfvars vs variables.tf
# What is a .tfvars file? This is a confusing topic as terraform.tfvars and variables.tf serve a similar role, as in both are variable files.
# However, a tfvars file stores the default values from a variables.tf file and allows you to override values if required.
# https://cloudbuild.co.uk/tag/tfvars-vs-variables-tf/
# https://spacelift.io/blog/terraform-tfvars

# *.tfvars are NOT committed in git when terraform is triggered manually from a laptop (containing sensitive data/credentials)
# Since this is triggered by Azure DevOps, we want to include *.tfvars to separate environments. Credentials are not saved here but in Azure KeyVault.

azure_subscription_unitedstates  = "00000000-0000-0000-0000-000000000004"   # Enterprise Core Subscription
azure_subscription_europe        = "00000000-0000-0000-0000-000000000004"   # Enterprise Core Subscription
deploy_Europe                    = true # AKS is deployed
deploy_United_States             = false
