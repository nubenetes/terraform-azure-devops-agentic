# https://learn.microsoft.com/en-us/azure/aks/concepts-identity
# https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac
# https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-rbac-admin


############################################################################
# Admin permissions granted to AAD developers group at a namespace scope
############################################################################

resource "azurerm_role_assignment" "aks_developers_rbac_admin_prometheus" {
  principal_id         = data.azuread_group.aks_developers.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  # Lets you manage all resources under cluster/namespace, except update or delete resource quotas and namespaces
  scope                            = join("", [data.azurerm_kubernetes_cluster.aks.id, "/namespaces/prometheus"])
  skip_service_principal_aad_check = false
}
