# What types of pods can prevent CA from removing a node? https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-types-of-pods-can-prevent-ca-from-removing-a-node
# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/kubernetes

#####################################################################################
# Infra node pool: This is where kube-prometheus-stack should be running
# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
#####################################################################################

# Create Linux Azure AKS Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "infra" {
  # availability_zones    = [1, 2, 3] #  An argument named "availability_zones" is not expected here
  enable_auto_scaling = true
  # https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 6
  min_count             = 1
  node_count            = 1
  mode                  = "User"
  name                  = "appspool001" # name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9
  #type                 = "VirtualMachineScaleSets"
  #node_taints          = ["app=gpu:NoSchedule"]   # https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
  #orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  orchestrator_version = var.kubernetes_version
  os_sku               = "AzureLinux" # https://www.hashicorp.com/blog/terraform-adds-support-azure-linux-container-host-azure-kubernetes-service
  os_disk_size_gb      = 30
  os_type              = "Linux" # Default is Linux, we can change to Windows
  vm_size              = "Standard_DS2_v2"
  priority             = "Regular"
  # (Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot.
  # Defaults to Regular. Changing this forces a new resource to be created.
  # When setting priority to Spot - you must configure an eviction_policy, spot_max_price and add the applicable node_labels and node_taints as per the Azure Documentation.
  #ultra_ssd_enabled     = true   #  (Optional) Used to specify whether the UltraSSD is enabled in the Node Pool. Defaults to false.
  zones          = [1]                                    # The Availability Zone identifier  # Availability zone is required for UltraSSD setting
  vnet_subnet_id = azurerm_subnet.aks_nodes_data_plane.id # (Optional) The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created.
  pod_subnet_id  = azurerm_subnet.aks_pods_data_plane.id  # (Optional) The ID of the Subnet where the pods in the Node Pool should exist. Changing this forces a new resource to be created.
  node_labels = {
    "nodepool-type" = "infra"
    "environment"   = local.environment
    "nodepoolos"    = "linux"
    "app"           = "infra"
  }
  lifecycle {
    # If you're specifying an initial number of nodes you may wish to use Terraform's ignore_changes functionality to ignore changes to this field.
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#ignore_changes
    ignore_changes = [
      node_count,
    ]
  }
  tags = {
    "nodepool-type" = "infra"
    "environment"   = local.environment
    "nodepoolos"    = "linux"
    "app"           = "infra"
  }
}
