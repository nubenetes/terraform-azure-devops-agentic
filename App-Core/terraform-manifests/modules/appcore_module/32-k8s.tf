# https://github.com/kubernetes/examples/tree/master/staging/volumes/azure_file
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1
# https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/job/main.tf
# https://learn.microsoft.com/en-us/azure/aks/concepts-storage
# https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision

resource "kubernetes_namespace_v1" "appcore_client" {
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

# resource "kubernetes_resource_quota_v1" "appcore_client" {
#   for_each             = toset(var.client_names)
#   metadata {
#     name = "ml-quota"
#     namespace = "appcore-${var.dns_child_zone}-${each.value}"
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
#     kubernetes_namespace_v1.appcore_client,
#   ]
# }


####################################################
# Enterprise namespace is no longer used
####################################################
# resource "kubernetes_secret_v1" "sa_Enterprise" {
#   metadata {
#     name = azurerm_storage_account.appcore.name
#     namespace = "Enterprise"
#   }

#   data = {
#     azurestorageaccountname = azurerm_storage_account.appcore.name
#     azurestorageaccountkey  = azurerm_storage_account.appcore.primary_access_key
#   }
#   type = "Opaque"
# }

resource "kubernetes_secret_v1" "sa_client" {
  for_each = toset(var.client_names)
  metadata {
    name      = azurerm_storage_account.appcore.name
    namespace = "${local.k8s_namespace_name}-${each.value}"
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.appcore.name
    azurestorageaccountkey  = azurerm_storage_account.appcore.primary_access_key
  }
  type = "Opaque"
  depends_on = [
    kubernetes_namespace_v1.appcore_client,
  ]
}

# https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims
resource "kubernetes_persistent_volume_claim_v1" "my_client" {
  for_each = toset(var.client_names)
  metadata {
    name      = each.value
    namespace = "${local.k8s_namespace_name}-${each.value}"
    # Set this annotation to NOT let Kubernetes automatically create
    # a persistent volume for this volume claim.
    # annotations = {
    #   volume.beta.kubernetes.io/storage-class = ""
    # }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.my_client[each.key].metadata.0.name
    #volume_name = "${each.value}"
    storage_class_name = "azurefile-csi"
  }
  depends_on = [
    kubernetes_namespace_v1.appcore_client,
  ]
}


# resource "kubernetes_persistent_volume_claim_v1" "my_client_ns" {
#   for_each              = toset(var.client_names)
#   metadata {
#     name = "asset"
#     namespace = "${local.k8s_namespace_name}-${each.value}"
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


resource "kubernetes_persistent_volume_v1" "my_client" {
  for_each = toset(var.client_names)
  metadata {
    name = "${var.Enterprise_product_k8s_prefix}-${each.value}-${local.instance_environment}"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Delete" #"Retain"
    storage_class_name               = "azurefile-csi"
    persistent_volume_source {
      azure_file {
        read_only        = "false"
        secret_name      = azurerm_storage_account.appcore.name
        secret_namespace = "Enterprise"
        share_name       = "fs-${var.Enterprise_product}-${each.value}-${local.instance_environment}"
      }
    }
  }
  depends_on = [
    azurerm_storage_share.fs_client,
  ]
}

# https://stackoverflow.com/questions/67345577/can-we-connect-multiple-pods-to-the-same-pvc
# ReadWriteOnce -- the volume can be mounted as read-write by a single node
# ReadOnlyMany -- the volume can be mounted read-only by many nodes
# ReadWriteMany -- the volume can be mounted as read-write by many nodes

######################################################################
# Developers' namespaces + permissions
# https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/
######################################################################

data "azuread_group" "aks_developers" {
  display_name     = local.aad_group_aks_developers_name
  security_enabled = true
}

resource "kubernetes_role_binding_v1" "appcore_client" {
  for_each = (local.sharedinfra_environment != "pro") ? toset(var.client_names) : []
  metadata {
    name      = "developers-${local.gitbranch}admin"
    namespace = "${local.k8s_namespace_name}-${each.value}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "developers-${local.gitbranch}admin"
  }
  # subject {
  #   kind      = "User"
  #   name      = "admin"
  #   api_group = "rbac.authorization.k8s.io"
  #   namespace = "applink-devtest"
  # }
  subject {
    kind      = "Group"
    namespace = "${local.k8s_namespace_name}-${each.value}"
    #name      = "system:masters"
    name = data.azuread_group.aks_developers.id
    #api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [
    kubernetes_namespace_v1.appcore_client,
  ]
}

resource "kubernetes_role_v1" "appcore_client" {
  for_each = (local.sharedinfra_environment != "pro") ? toset(var.client_names) : []
  metadata {
    name      = "developers-${local.gitbranch}admin"
    namespace = "${local.k8s_namespace_name}-${each.value}"
    labels = {
      test = "MyDevelopersAdminRole"
    }
  }

  rule {
    api_groups = ["", "extensions", "apps"] # "" indicates the core API group
    #resources      = ["services","pods","deployments"]
    resources = ["*"]
    verbs     = ["*"]
    # Rather than referring to individual resources and verbs you can use the wildcard * symbol to refer to all such objects.
    # For nonResourceURLs you can use the wildcard * symbol as a suffix glob match and for apiGroups and resourceNames an empty set means that everything is allowed.
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
    # Rather than referring to individual resources and verbs you can use the wildcard * symbol to refer to all such objects.
    # For nonResourceURLs you can use the wildcard * symbol as a suffix glob match and for apiGroups and resourceNames an empty set means that everything is allowed.
  }
  depends_on = [
    kubernetes_namespace_v1.appcore_client,
  ]
}

######################################################################
# Developers' namespaces + permissions
# https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/
######################################################################

# resource "kubernetes_namespace_v1" "applink-devtest" {
#   count = (local.sharedinfra_environment != "pro") ? 1:0
#   metadata {
#     annotations = {
#       name = "applink-${local.gitbranch}${var.environment}"
#     }
#     labels = {
#       app = "applink-${local.gitbranch}${var.environment}"
#       environment = var.environment
#     }
#     name = "applink-${local.gitbranch}${var.environment}"
#   }
# }

# resource "kubernetes_role_binding_v1" "applink-devtest" {
#   count = (local.sharedinfra_environment != "pro") ? 1:0
#   metadata {
#     name      = "developers-${local.gitbranch}admin"
#     namespace = "applink-${local.gitbranch}${var.environment}"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = "developers-${local.gitbranch}admin"
#   }
#   # subject {
#   #   kind      = "User"
#   #   name      = "admin"
#   #   api_group = "rbac.authorization.k8s.io"
#   #   namespace = "applink-devtest"
#   # }
#   subject {
#     kind      = "Group"
#     namespace = "applink-${local.gitbranch}${var.environment}"
#     #name      = "system:masters"
#     name      = data.azuread_group.aks_developers.id
#     #api_group = "rbac.authorization.k8s.io"
#   }
# }


# resource "kubernetes_role_v1" "applink-devtest" {
#   count = (local.sharedinfra_environment != "pro") ? 1:0
#   metadata {
#     name = "developers-${local.gitbranch}admin"
#     namespace = "applink-${local.gitbranch}${var.environment}"
#     labels = {
#       test = "MyDevelopersAdminRole"
#     }
#   }

#   rule {
#     api_groups     = ["", "extensions", "apps"] # "" indicates the core API group
#     #resources      = ["services","pods","deployments"]
#     resources      = ["*"]
#       # Rather than referring to individual resources and verbs you can use the wildcard * symbol to refer to all such objects.
#       # For nonResourceURLs you can use the wildcard * symbol as a suffix glob match and for apiGroups and resourceNames an empty set means that everything is allowed.
#     verbs          = ["*"]
#       # Rather than referring to individual resources and verbs you can use the wildcard * symbol to refer to all such objects.
#       # For nonResourceURLs you can use the wildcard * symbol as a suffix glob match and for apiGroups and resourceNames an empty set means that everything is allowed.
#   }
#   rule {
#     api_groups     = ["batch"]
#     resources      = ["jobs","cronjobs"]
#     verbs          = ["*"]
#       # Rather than referring to individual resources and verbs you can use the wildcard * symbol to refer to all such objects.
#       # For nonResourceURLs you can use the wildcard * symbol as a suffix glob match and for apiGroups and resourceNames an empty set means that everything is allowed.
#   }
# }
