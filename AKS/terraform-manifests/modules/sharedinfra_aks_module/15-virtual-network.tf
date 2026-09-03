# https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
# An Azure Kubernetes Service (AKS) cluster configured with API Server VNet Integration (Preview) projects the API server endpoint directly into a delegated subnet in the VNet where AKS is deployed. 
# API Server VNet Integration enables network communication between the API server and the cluster nodes without requiring a private link or tunnel. 
# The API server is available behind an Internal Load Balancer VIP in the delegated subnet, which the nodes are configured to utilize. By using API Server VNet Integration, 
# you can ensure network traffic between your API server and your node pools remains on the private network only.
#
# API server connectivity
# The control plane or API server is in an Azure Kubernetes Service (AKS)-managed Azure subscription. A customer's cluster or node pool is in the customer's subscription. 
# The server and the virtual machines that make up the cluster nodes can communicate with each other through the API server VIP and pod IPs that are projected into the delegated subnet.
#
# API Server VNet Integration is supported for public or private clusters, and public access can be added or removed after cluster provisioning. 
# Unlike non-VNet integrated clusters, the agent nodes always communicate directly with the private IP address of the API Server Internal Load Balancer (ILB) IP without using DNS. 
# All node to API server traffic is kept on private networking and no tunnel is required for API server to node connectivity. 
# Out-of-cluster clients needing to communicate with the API server can do so normally if public network access is enabled. If public network access is disabled, they should follow the same private DNS setup methodology as standard private clusters.
#
# Register the 'EnableAPIServerVnetIntegrationPreview' feature flag
#
# Limitations
# Existing AKS private clusters can't be converted to API Server VNet Integration clusters.
# Private Link Service won't work if deployed against the API Server injected addresses. 
# The API server can't be exposed to other virtual networks using private link. To access the API server from outside the cluster network, utilize either VNet peering or AKS run command.
#
# Create an AKS cluster with API Server VNet Integration using Managed VNet
# AKS clusters with API Server VNet Integration can be configured in either managed VNet or bring-your-own VNet mode. 
# They can be created as either public clusters (with API server access available via a public IP) or private clusters (where the API server is only accessible via private VNet connectivity), and can be toggled between these two states without redeploying.
#
# Create an AKS Private cluster with API Server VNet Integration using bring-your-own VNet
# When using bring-your-own VNet, an API server subnet must be created and delegated to Microsoft.ContainerService/managedClusters. 
# This grants the AKS service permissions to inject the API server pods and internal load balancer into that subnet. The subnet may not be used for any other workloads, but may be used for multiple AKS clusters located in the same virtual network. 
# An AKS cluster will require from 2-7 IP addresses depending on cluster scale. The minimum supported API server subnet size is a /28.
# The cluster identity needs permissions to both the API server subnet and the node subnet. Lack of permissions at the API server subnet can cause a provisioning failure.
#
# Convert an existing AKS cluster to API Server VNet Integration
# Existing AKS public clusters can be converted to API Server VNet Integration clusters by supplying an API server subnet that meets the requirements listed earlier (in the same VNet as the cluster nodes, permissions granted for the AKS cluster identity, and size of at least /28). 
# This is a one-way migration; clusters can't have API Server VNet Integration disabled after it's been enabled.
# This upgrade performs a node-image version upgrade on all node pools - all workloads are restarted while they undergo a rolling image upgrade.

# Create Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet-${local.environment}"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = ["10.0.0.0/8"]
}

############################################################
# API server subnet
# The Subnet where the API server endpoint is delegated to
# https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
############################################################
resource "azurerm_subnet" "aks_api_server" {
  name                 = "aks-control-plane-pods-subnet-${local.environment}"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  address_prefixes     = ["10.1.0.0/28"]
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      #actions = ["Microsoft.Network/virtualNetworks/subnets/joinLoadBalancer/action"]
      actions = [
        #"Microsoft.Network/networkinterfaces/*",
        #"Microsoft.Network/publicIPAddresses/join/action",
        #"Microsoft.Network/publicIPAddresses/read",
        #"Microsoft.Network/virtualNetworks/read",
        #"Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        #"Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        #"Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}
############################################################
# Node Subnet - Subnet for AKS nodes - data plane
# https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
############################################################
resource "azurerm_subnet" "aks_nodes_data_plane" {
  name                 = "aks-data-plane-nodes-subnet-${local.environment}"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  address_prefixes     = ["10.0.32.0/19"] # To allow plenty of room for growth while reducing the total number of addresses to a manageable level, we choose a 19-bit netmask that provides 8,192 addresses
}
resource "azurerm_subnet" "aks_pods_data_plane" {
  name                 = "aks-data-plane-pods-subnet-${local.environment}"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.rg_aks.name
  address_prefixes     = ["10.0.64.0/19"] # To allow plenty of room for growth while reducing the total number of addresses to a manageable level, we choose a 19-bit netmask that provides 8,192 addresses
}

# Network Profile
# Kubenet is a kubernetes network configuration plugin for your AKS cluster. Nodes get an IP address from
# the AKS subnet, and pods receive an IP address from a separate address space entirely. The source IP address
# of the traffic is NAT'd to the node's IP address.

# With kubenet there's NO Pod-to-Pod communication because they don't have their own public IPs.
# User Defined Routing (UDR) and IP forwarding is used for communication between pods across nodes.

# Kubenet is the preferred method since you get more pods per node and the AKS Cluster scales to a bigger number.
# With kubenet Max Number of Pods per Node: 110
# With Kubenet and CIDR =/24 : 251 nodes * 110 pods per node = 27.610 pods
# With Azure CNI (instead of kubenet) and CIDR =/24 : 8 nodes * 30 pods per node = 240 pods

# If we have limited IP addresses to work with, we can fit more pods in the limited IP address space because we can
# fit more pods per node.

# The Service CIDR, Pod CIDR, and Docker Bridge Access can be any address range.
# The DNS Service IP must be any IP address that's within the Service CIDR address range.

# Network settings (service_cidr, pod_cidr, docker_bridge_cidr, dns_service_ip) are commented. The below values
# correspond to the applied default values when these settings are note set up.

# Default network settings with kubenet when they are not configured:
# Azure AKS VNet      = "10.0.0.0/8"
# Azure AKS Subnet    = "10.240.0.0/16"
# service_cidr        = "10.0.0.0/16"
# pod_cidr            = "10.244.0.0/16"
# docker_bridge_cidr  = "172.17.0.1/16" # Default. You can reuse this range across different AKS Clusters
# dns_service_ip      = "10.0.0.10"