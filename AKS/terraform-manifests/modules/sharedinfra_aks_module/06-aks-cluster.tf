# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/kubernetes

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = azurerm_resource_group.rg_aks.name
  location            = azurerm_resource_group.rg_aks.location
  name                = local.aks_cluster_name
  resource_group_name = azurerm_resource_group.rg_aks.name
  kubernetes_version  = var.kubernetes_version
  #kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version # Latest available AKS is setup
  # (Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade).
  # AKS does not require an exact patch version to be specified, minor version aliases such as 1.22 are also supported. - The minor version's latest GA patch is automatically chosen in that case.
  node_resource_group     = "${azurerm_resource_group.rg_aks.name}-nodes" # without this another RG named "MC_rg-aks-dev_aks-dev_northeurope" is created
  private_cluster_enabled = false                                         #  (Optional) Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?
  # This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created.
  local_account_disabled = false # If local_account_disabled is set to true, it is required to enable Kubernetes RBAC and AKS-managed Azure AD integration. https://docs.microsoft.com/azure/aks/managed-aad#azure-ad-authentication-overview
  # Azure Kubernetes Service (AKS) now allows for Azure Active Directory (AAD) integrated clusters to be created without any local admin user account.
  # By default, when you create a Kubernetes cluster, access to the cluster is through a local admin account.  This is not desirable for security reasons as anyone can use a local account. It is also harder to manage such local accounts.
  # With AAD integration, there is no need for local accounts. This feature, now in public preview, allows you to disable local accounts when you setup AAD with your AKS cluster.
  # Access and identity options for Azure Kubernetes Service (AKS): https://learn.microsoft.com/en-us/azure/aks/concepts-identity
  role_based_access_control_enabled = true # (Optional) Whether Role Based Access Control for the Kubernetes Cluster should be enabled. Defaults to true. Changing this forces a new resource to be created.
  workload_identity_enabled         = true # (Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false.
  # To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true.
  # This requires that the Preview Feature Microsoft.ContainerService/EnableWorkloadIdentityPreview is enabled and the Resource Provider is re-registered
  # https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#register-the-enableworkloadidentitypreview-feature-flag
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration#example-usage-registering-a-preview-feature
  # AKS Workload Identity is a feature in Azure Kubernetes Service that allows a Kubernetes Pod running on AKS to securely authenticate against other Azure service using an Azure Active Directory (Azure AD) identity. With AKS Workload Identitity,
  # you can give your kubernetes workloads fine-grained access to other Azure resources without exposing any sensitive credentials in your Pod's configuration or code.
  # Traditionally, kubernetes pods have used kubernetes service account tokens to authenticate againsts other Azure services, but these tokens have limitations in terms of their lifespan and access permissions. With AKW Workload Identity,
  # you can map a kubernetes service account to an Azure AD identity, which enables the Pod to use its Azure AD identity to authenticate with Azure services, such as Azure Key Vault, Azure Storage, or Azure CosmosDB, with more granular permissions.
  # AKS Workload Identity is especially useful for enterprises that required fine-grained access controls, centralized policy management, and audit logging for their kubernetes workloads in Azure.
  oidc_issuer_enabled = true
  # (Optional) Enable or Disable the OIDC issuer URL - https://learn.microsoft.com/en-gb/azure/aks/use-oidc-issuer
  # https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens
  #oidc_issuer_url         = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
  # https://azure.github.io/azure-workload-identity/docs/installation/self-managed-clusters/oidc-issuer.html
  # Can't configure a value for "oidc_issuer_url": its value will be decided automatically based on the result of applying this configuration.
  azure_policy_enabled = true # (Optional) Should the Azure Policy Add-On be enabled? For more details please visit https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/rego-for-aks
  #http_application_routing_enabled = true
  # Enabling addon-http-application-routing-nginx-ingress + addon-http-application-routing-external-dns
  # Installs Ingress Nginx
  # Installs the ExternalDNS that can be used to manage DNS entries automatically.
  # Azure creates an L4 Load Balancer and configures it to route traffic to the Ingress Nginx.
  # The HTTP application routing solution makes it easy to access applications that are deployed to your cluster by creating publicly accessible DNS names for application endpoints.
  # This will create a DNS zone in your subscription. HTTP application routing is designed for easily getting started with ingress controllers and as such is not recommended for production clusters.
  # https://learn.microsoft.com/en-us/azure/aks/http-application-routing
  public_network_access_enabled = true # (Optional) Whether public network access is allowed for this Kubernetes Cluster. Defaults to true. Changing this forces a new resource to be created.
  # When public_network_access_enabled is set to true, 0.0.0.0/32 must be added to authorized_ip_ranges in the api_server_access_profile block.

  #################################################################
  # nginx ingress controller + external-dns controller
  # https://learn.microsoft.com/en-us/azure/aks/web-app-routing
  #################################################################
  web_app_routing {
    # https://github.com/Azure-Samples/azure-opensource-labs/tree/main/cloud-native/aks-webapp-routing
    # az aks show -n aks-dneeng -g rg-sharedinfra-aks-dneeng --query ingressProfile
    dns_zone_id = data.azurerm_dns_zone.my_dns.id
  }

  # https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
  # https://medium.com/nerd-for-tech/kubernetes-cluster-autoscaler-in-action-6172a023f542
  auto_scaler_profile {
    balance_similar_node_groups = true        #(Optional) Detect similar node groups and balance the number of nodes between them. Defaults to false.
    expander                    = "most-pods" # (Optional) Expander to use. Possible values are least-waste, priority, most-pods and random. Defaults to random.
    # https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders
    max_graceful_termination_sec     = 600    # (Optional) Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to 600
    max_node_provisioning_time       = "15m"  # (Optional) Maximum time the autoscaler waits for a node to be provisioned. Defaults to 15m
    max_unready_nodes                = 3      # (Optional) Maximum Number of allowed unready nodes. Defaults to 3.
    max_unready_percentage           = 45     # (Optional) Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to 45.
    new_pod_scale_up_delay           = "180s" # (Optional) For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to 10s.
    scale_down_delay_after_add       = "2m"   # (Optional) How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to 10m.
    scale_down_delay_after_delete    = "10s"  # (Optional) How long after node deletion that scale down evaluation resumes. Defaults to the value used for scan_interval
    scale_down_delay_after_failure   = "2m"   # (Optional) How long after scale down failure that scale down evaluation resumes. Defaults to 3m.
    scan_interval                    = "10s"  # (Optional) How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to 10s.
    scale_down_unneeded              = "2m"   # (Optional) How long a node should be unneeded before it is eligible for scale down. Defaults to 10m.
    scale_down_unready               = "20m"  # (Optional) How long an unready node should be unneeded before it is eligible for scale down. Defaults to 20m.
    scale_down_utilization_threshold = 0.5    # (Optional) Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to 0.5.
    empty_bulk_delete_max            = 10     # (Optional) Maximum number of empty nodes that can be deleted at the same time. Defaults to 10.
    skip_nodes_with_local_storage    = false  # (Optional) If true cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to true.
    skip_nodes_with_system_pods      = false  # (Optional) If true cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to true.
  }
  default_node_pool {
    name    = "systempool" # name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9
    vm_size = "Standard_DS2_v2"
    #orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    orchestrator_version = var.kubernetes_version
    #node_taints          = ["CriticalAddonsOnly=true:NoSchedule"]  # <- still not supported, use "only_critical_addons_enabled" instead
    # Error: expanding `default_node_pool`: The AKS API has removed support for tainting all nodes in the default node pool and it is no longer possible to configure this. To taint a node pool, create a separate one.
    # https://github.com/hashicorp/terraform-provider-azurerm/issues/10490
    # A mode of type System is defined for system node pools, and a mode of type User is defined for user node pools.
    # For a system pool, verify the taint is set to CriticalAddonsOnly=true:NoSchedule, which will prevent application pods from beings scheduled on this node pool.
    # https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#add-a-dedicated-system-node-pool-to-an-existing-aks-cluster
    # https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
    # https://stackoverflow.com/questions/74445188/azure-kubernetes-system-and-user-pool
    only_critical_addons_enabled = true # (Optional) Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. Changing this forces a new resource to be created.
    enable_auto_scaling          = true
    zones                        = [1] # The Availability Zone identifier
    type                         = "VirtualMachineScaleSets"
    max_count                    = 3
    min_count                    = 1
    os_sku                       = "AzureLinux" # https://www.hashicorp.com/blog/terraform-adds-support-azure-linux-container-host-azure-kubernetes-service
    os_disk_size_gb              = 30
    vnet_subnet_id               = azurerm_subnet.aks_nodes_data_plane.id #  (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created.
    # A Route Table must be configured on this Subnet.
    pod_subnet_id = azurerm_subnet.aks_pods_data_plane.id # (Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created.
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = local.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = local.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  # Identity (System Assigned or Service Principal)
  #identity { type = "SystemAssigned" }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_cluster.id] # (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster.
    # This is required when type is set to UserAssigned.
  } # System-assigned managed identity not supported for custom resource subnets/aks-control-plane-pods-subnet-dneeng. Please use user-assigned managed identity

  azure_active_directory_role_based_access_control {
    # This requires that the Preview Feature Microsoft.ContainerService/AKS-PrometheusAddonPreview is enabled, see the documentation for more information.
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.id]
    azure_rbac_enabled     = true
  }

  # monitor_metrics {
  #   #(Optional) Specifies a Prometheus add-on profile for the Kubernetes Cluster.
  #   annotations_allowed = [] # (Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric.
  #   labels_allowed      = [] # (Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.
  # }

  api_server_access_profile {
    #authorized_ip_ranges = ["198.51.100.0/24"]
    #authorized_ip_ranges      = ["0.0.0.0/32"] # When public_network_access_enabled is set to true, 0.0.0.0/32 must be added to authorized_ip_ranges in the api_server_access_profile block.
    subnet_id = azurerm_subnet.aks_api_server.id # (Optional) The ID of the Subnet where the API server endpoint is delegated to.
    # apiServerAccessProfile.subnetId should be empty when using default vnet with apiserverVnetIntegration
    vnet_integration_enabled = true # This requires that the Preview Feature Microsoft.ContainerService/EnableAPIServerVnetIntegrationPreview is enabled and the Resource Provider is re-registered, see the documentation for more information.
    # This requires that the Preview Feature Microsoft.ContainerService/EnableAPIServerVnetIntegrationPreview is enabled and the Resource Provider is re-registered, see the documentation for more information.
  }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Network Profile
  # Kubenet is a kubernetes network configuration plugin for your AKS cluster. Nodes get an IP address from
  # the AKS subnet, and pods receive an IP address from a separate address space entirely. The source IP address
  # of the traffic is NAT'd to the node's IP address.

  # With kubenet there's NO Pod-to-Pod communication because they don't have their own public IPs.
  # User Defined Routing (UDR) and IP forwarding is used for communication between pods across nodes.

  # Kubenet is the preferred method since you get more pods per node and the AKS cluster scales to a bigger number.
  # With Kubenet Max Number of Pods per Node: 110
  # With Kubenet and CIDR = /24 : 251 nodes * 110 pods per node = 27.610 pods
  # With Azure CNI (instead of kubenet) and CIDR = /24 : 8 nodes * 30 pods per node = 240 pods

  # If we have limited IP addresses to work with, we can fit more pods in the limited IP address space because
  # we can fit more pods per node.

  # The Service CIDR, Pod CIDR, and Docker Bridge Access can be any address range.
  # The DNS Service IP must be any IP address that's within the Service CIDR address range.

  # Network settings (service_cidr, pod_cidr, docker_bridge_cidr, dns_service_ip) are commented. The below values
  # correspond to the applied default values when these settings are not set up. In our scenario these default vault
  # values are applied to both AKS Clusters (dev & qa).
  # Default network settings with kubenet when they are not configured:
  # Azure AKS VNet     = "10.0.0.0/8"
  # Azure AKS Subnet   = "10.240.0.0/16"
  # service_cidr       = "10.0.0.0/16"
  # pod_cidr           = "10.244.0.0/16"
  # docker_bridge_cidr = "172.17.0.1/16" # Default. You can reuse this range across different AKS clusters.
  # dns_service_ip     = "10.0.0.10"

  network_profile {
    load_balancer_sku = "standard"
    #network_plugin      = "kubenet"   # If network_profile is not defined, kubenet profile will be used by default.
    network_plugin = "azure"
    # When network_plugin is set to azure - the vnet_subnet_id field in the default_node_pool block must be set and pod_cidr must not be set.
    service_cidr = "10.0.0.0/19"
    #pod_cidr = "10.244.0.0/16"
    #pod_cidr            = azurerm_subnet.aks_data_plane_pods.address_prefixes[0]
    #docker_bridge_cidr  = "172.17.0.1/16" # Default. You can reuse this range across different AKS clusters.
    # `docker_bridge_cidr` has been deprecated as the API no longer supports it and will be removed in version 4.0 of the provider.
    dns_service_ip = "10.0.0.10"
  }

  # AKS Cluster Tags
  tags = {
    environment = local.environment
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_cluster.id
  }

  # https://learn.microsoft.com/en-us/azure/aks/web-app-routing?tabs=without-osm#create-and-export-a-self-signed-ssl-certificate-if-you-dont-already-own-one
  key_vault_secrets_provider {
    secret_rotation_enabled = true # (Optional) Should the secret store CSI driver on the AKS cluster be enabled?
  }
  # key_management_service {
  #   key_vault_key_id =
  #   key_vault_network_access = "Public"
  # }

  depends_on = [
    azurerm_resource_provider_registration.aks_cluster,
  ]

}


##############################################################################################################################
# Use Kubernetes Service Accounts in Terraform for AKS clusters with AAD integration
# Use Service Accounts in AKS clusters with AAD integration to not gain admin credentials to Terraform and DevOps pipelines.
# https://pumpingco.de/blog/use-service-accounts-for-terraform-with-aad-integrated-aks-clusters/
##############################################################################################################################

# # Create a Service Account
# resource "kubernetes_service_account" "example" {
#   automount_service_account_token = true

#   metadata {
#     name = "terraform-example"
#   }
# }

# # Add the Secret, that holds the Service Account Token as a data source
# data "kubernetes_secret" "example" {
#   metadata {
#     name = "${kubernetes_service_account.example.default_secret_name}"
#   }
# }

# # Create a new Role for the Service Account
# resource "kubernetes_cluster_role" "example" {
#   metadata {
#     name = "terraform-example"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["namespaces"]
#     verbs      = ["get", "list", "update", "create", "patch"]
#   }
# }

# # Assign the Role to the Service Account
# resource "kubernetes_cluster_role_binding" "example" {
#   provider = kubernetes.admin

#   metadata {
#     name = "terraform-example"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.example.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.example.metadata[0].name
#   }
# }


###################################
# DNS ZONE AND DNS SUBDOMAINS
##################################
data "azurerm_dns_zone" "my_dns" {
  name                = local.dns_zone
  resource_group_name = local.dns_resource_group_name
}

####################################################################################################
# webapprouting-aks-dneeng - Nginx-ingress + external-dns controllers in AKS
# 06-aks-cluster.tf - azurerm_kubernetes_cluster.aks_cluster.web_app_routing
###################################################################################################
data "azuread_service_principal" "webapprouting" {
  display_name = "webapprouting-${local.aks_cluster_name}"
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
  ]
}

####################################################################################################
# RBAC - DNS Zone Contributor
####################################################################################################
resource "azurerm_role_assignment" "webapprouting_dns_zone_contributor" {
  role_definition_name = "DNS Zone Contributor" # Built-in Role
  principal_id         = data.azuread_service_principal.webapprouting.object_id
  scope                = data.azurerm_dns_zone.my_dns.id # DNS Zone Scope
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
  ]
}

####################################################################################################
# AKS - User Assigned Identity
####################################################################################################
resource "azurerm_user_assigned_identity" "aks_cluster" {
  location            = azurerm_resource_group.rg_aks.location
  name                = "identity-${local.aks_cluster_name}"
  resource_group_name = azurerm_resource_group.rg_aks.name
}


# resource "azurerm_role_assignment" "webapprouting" {
#   role_definition_name = "Key Vault Reader"
#   principal_id         = data.azuread_service_principal.webapprouting.id
#   scope                = data.azurerm_key_vault.wildcards_Enterprise_com.id
# }


data "azurerm_key_vault" "wildcards_Enterprise_com" {
  provider = azurerm.manualinfra
  # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
  name                = "kv-wildcards-Enterprise-com"
  resource_group_name = "CertificatesResourceGroup"
}

# https://learn.microsoft.com/en-us/azure/aks/web-app-routing?tabs=without-osm#create-and-export-a-self-signed-ssl-certificate-if-you-dont-already-own-one
# data "azurerm_key_vault" "wildcards_Enterprise_com" {
#   name                = "kv-azuredevops-library2"
#   resource_group_name = "rg-azuredevops-pro"
# }


# data "azurerm_key_vault_certificate" "wildcards_Enterprise_com" {
#   provider     = azurerm.manualinfra
#     # NOTE: The vault must be in the same subscription as the provider. If the vault is in another subscription, you must create an aliased provider for that subscription.
#   name         = "cert-wildcard-Enterprise-${local.environment}"
#   key_vault_id = data.azurerm_key_vault.wildcards_Enterprise_com.id
# }