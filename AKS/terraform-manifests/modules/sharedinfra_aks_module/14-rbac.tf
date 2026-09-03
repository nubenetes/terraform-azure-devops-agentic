##############################################################################################################################################################################
# Example Usage: Attaching a Container Registry to a Kubernetes Cluster
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry#example-usage-attaching-a-container-registry-to-a-kubernetes-cluster
##############################################################################################################################################################################

# ACR deployed with terraform is currently disabled:

# resource "azurerm_role_assignment" "aks_acr_rbac" {
#   principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }


###################################################
# Legacy ACR (manually setup without terraform):
###################################################
resource "azurerm_role_assignment" "aks_legacy_acr_rbac" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_subscription.current.id
  skip_service_principal_aad_check = true
}


####################################################################################################################################################################################
# Create an Azure Kubernetes Service cluster with API Server VNet Integration (Preview) - Create an AKS Private cluster with API Server VNet Integration using bring-your-own VNet
# https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration#create-a-managed-identity-and-give-it-permissions-on-the-virtual-network
####################################################################################################################################################################################
resource "azurerm_role_assignment" "aks_api_server_subnet" {
  principal_id                     = azurerm_user_assigned_identity.aks_cluster.principal_id
  role_definition_name             = "Network Contributor"
  scope                            = azurerm_subnet.aks_api_server.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_data_plane_nodes" {
  principal_id                     = azurerm_user_assigned_identity.aks_cluster.principal_id
  role_definition_name             = "Network Contributor"
  scope                            = azurerm_subnet.aks_nodes_data_plane.id
  skip_service_principal_aad_check = true
}


###################################################################################################################################
# Create Azure AD Group in Active Directory for AKS Admins
# Access and identity options for Azure Kubernetes Service (AKS): https://learn.microsoft.com/en-us/azure/aks/concepts-identity
# Linked to azurerm_kubernetes_cluster.aks_cluster.azure_active_directory_role_based_access_control.admin_group_object_ids
###################################################################################################################################
resource "azurerm_role_assignment" "aks_administrators_cluster_admin" {
  principal_id         = azuread_group.aks_administrators.object_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role" # List cluster admin credential action
  #"Azure Kubernetes Service RBAC Cluster Admin"
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = false
}

###################################################################################################################################
# Create Azure AD Group in Active Directory for AKS Developers
# Access and identity options for Azure Kubernetes Service (AKS): https://learn.microsoft.com/en-us/azure/aks/concepts-identity
# https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac
# https://www.returngis.net/2022/05/crear-roles-personalizados-para-la-nueva-integracion-de-aks-con-azure-active-directory
###################################################################################################################################
resource "azurerm_role_assignment" "aks_developers_cluster_user" {
  # https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac
  principal_id                     = azuread_group.aks_developers.object_id
  role_definition_name             = "Azure Kubernetes Service Cluster User Role" # List cluster user credential action
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = false
}
resource "azurerm_role_assignment" "aks_developers_cluster_monitoring_user" {
  principal_id                     = azuread_group.aks_developers.object_id
  role_definition_name             = "Azure Kubernetes Service Cluster Monitoring User" # List cluster monitoring user credential action
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "aks_developers_rbac_reader" {
  principal_id         = azuread_group.aks_developers.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  # Allows read-only access to see most objects in a namespace. It doesn't allow viewing roles or role bindings.
  # This role doesn't allow viewing Secrets, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation).
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = false
}
