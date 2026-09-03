# What types of pods can prevent CA from removing a node? https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-types-of-pods-can-prevent-ca-from-removing-a-node
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/kubernetes

# Create Linux Azure AKS Node Pool

# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/spot-node-pool/main.tf
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  max_count             = 10
  min_count             = 0
  node_count            = 0 #1
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = 0.5                                    # note: this is the "maximum" price
  vnet_subnet_id        = azurerm_subnet.aks_nodes_data_plane.id # (Optional) The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created.
  pod_subnet_id         = azurerm_subnet.aks_pods_data_plane.id  # (Optional) The ID of the Subnet where the pods in the Node Pool should exist. Changing this forces a new resource to be created.
  os_sku                = "AzureLinux"                           # https://www.hashicorp.com/blog/terraform-adds-support-azure-linux-container-host-azure-kubernetes-service
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  lifecycle {
    # If you're specifying an initial number of nodes you may wish to use Terraform's ignore_changes functionality to ignore changes to this field.
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes
    ignore_changes = [
      node_count,
    ]
  }
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}