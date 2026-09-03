# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group


data "azuread_user" "group_owner" {
  user_principal_name = "cloud-admin@example.com"
}

data "azuread_users" "aks_developers" {
  #user_principal_names = ["cloud-admin@example.com", "cloud-admin@example.com"]
  user_principal_names = var.aks_developers
}

data "azuread_users" "aks_administrators" {
  #user_principal_names = ["cloud-admin@example.com", "cloud-admin@example.com"]
  user_principal_names = var.aks_administrators
}

data "azuread_service_principals" "aks_administrators" {
  display_names = var.service_principals_with_aad_aks_cluster_admin_role
}


# Create Azure AD Group in Active Directory for AKS Admins
# Access and identity options for Azure Kubernetes Service (AKS): https://learn.microsoft.com/en-us/azure/aks/concepts-identity
# Linked to azurerm_kubernetes_cluster.aks_cluster.azure_active_directory_role_based_access_control.admin_group_object_ids
resource "azuread_group" "aks_administrators" {
  display_name       = local.aad_group_aks_admins_name
  description        = "AKS Administrators for the ${local.aks_cluster_name} Cluster. Group created by DevOps Azure and Terraform"
  security_enabled   = true
  assignable_to_role = true # (Optional) Indicates whether this group can be assigned to an Azure Active Directory role. Can only be true for security-enabled groups.
  # If using the assignable_to_role property, this resource additionally requires the following application roles: RoleManagement.ReadWrite.Directory
  owners = [data.azuread_client_config.current.object_id, data.azuread_user.group_owner.object_id]
  #types              = ["Unified"]
  members = setunion(
    #[data.azuread_user.group_owner.object_id],
    data.azuread_users.aks_administrators.object_ids,
    data.azuread_service_principals.aks_administrators.object_ids,
  )
}


# Create Azure AD Group in Active Directory for AKS Developers
# Access and identity options for Azure Kubernetes Service (AKS): https://learn.microsoft.com/en-us/azure/aks/concepts-identity
resource "azuread_group" "aks_developers" {
  display_name       = local.aad_group_aks_developers_name
  description        = "AKS Developers for the ${local.aks_cluster_name} Cluster. Group created by DevOps Azure and Terraform"
  security_enabled   = true
  assignable_to_role = true # (Optional) Indicates whether this group can be assigned to an Azure Active Directory role. Can only be true for security-enabled groups.
  # If using the assignable_to_role property, this resource additionally requires the following application roles: RoleManagement.ReadWrite.Directory
  owners = [data.azuread_client_config.current.object_id, data.azuread_user.group_owner.object_id]
  #types              = ["Unified"]
  members = setunion(
    #[data.azuread_user.group_owner.object_id],
    data.azuread_users.aks_developers.object_ids,
  )
}