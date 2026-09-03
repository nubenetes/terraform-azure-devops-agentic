# https://github.com/kubernetes/examples/tree/master/staging/volumes/azure_file
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1
# https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/job/main.tf
# https://learn.microsoft.com/en-us/azure/aks/concepts-storage
# https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision

resource "kubernetes_namespace_v1" "appanalysis_client" {
  for_each = toset(var.client_names)
  metadata {
    annotations = {
      name = "ml"
    }
    labels = {
      app         = "ml"
      environment = var.environment
    }
    name = "${local.k8s_namespace_name}-${each.value}"
  }
}

# resource "kubernetes_resource_quota_v1" "App-Core_client" {
#   for_each             = toset(var.client_names)
#   metadata {
#     name = "ml-quota"
#     namespace = "App-Core-${var.dns_child_zone}-${each.value}"
#   }
#   spec {
#     hard = {
#       pods = 10
#       cpu = 8
#       memory = "50Gi"
#       #cpu = 9.72
#       #memory = "61.0Gi"
#       configmaps = 8
#       persistentvolumeclaims = 8
#       secrets = 8
#       services = 8
#     }
#     #scopes = ["BestEffort"]
#   }
#   depends_on = [
#     kubernetes_namespace_v1.App-Core_client,
#   ]
# }

resource "kubernetes_secret_v1" "sa_Enterprise" {
  for_each = toset(var.client_names)
  metadata {
    name      = azurerm_storage_account.sa_appanalysis[each.key].name
    namespace = "Enterprise"
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.sa_appanalysis[each.key].name
    azurestorageaccountkey  = azurerm_storage_account.sa_appanalysis[each.key].primary_access_key
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "sa_client" {
  for_each = toset(var.client_names)
  metadata {
    name      = azurerm_storage_account.sa_appanalysis[each.key].name
    namespace = "${local.k8s_namespace_name}-${each.value}"
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.sa_appanalysis[each.key].name
    azurestorageaccountkey  = azurerm_storage_account.sa_appanalysis[each.key].primary_access_key
  }
  type = "Opaque"
  depends_on = [
    kubernetes_namespace_v1.appanalysis_client,
  ]
}

# resource "kubernetes_persistent_volume_claim_v1" "my_client" {
#   for_each              = toset(var.client_names)
#   metadata {
#     name = "${each.value}"
#     namespace = "Enterprise"
#     # Set this annotation to NOT let Kubernetes automatically create
#     # a persistent volume for this volume claim.
#     # annotations = {
#     #   volume.beta.kubernetes.io/storage-class = ""
#     # }
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#     volume_name = "${kubernetes_persistent_volume_v1.my_client[each.key].metadata.0.name}"
#     #volume_name = "${each.value}"
#     storage_class_name = "azurefile-csi"
#   }
# }

# resource "kubernetes_persistent_volume_v1" "my_client" {
#   for_each              = toset(var.client_names)
#   metadata {
#     name = "${each.value}"
#   }
#   spec {
#     capacity = {
#       storage = "1Gi"
#     }
#     access_modes = ["ReadWriteMany"]
#     persistent_volume_reclaim_policy = "Retain" #"Delete"
#     storage_class_name = "azurefile-csi"
#     persistent_volume_source {
#       azure_file {
#         read_only        = "false"
#         secret_name      = azurerm_storage_account.App-Core.name
#         secret_namespace = "Enterprise"
#         share_name       = "fs-${var.Enterprise_product}-${each.value}-${local.gitbranch}${var.location_code}${var.environment}"
#       }
#     }
#   }
#   depends_on = [
#     azurerm_storage_share.fs_client,
#   ]
# }
