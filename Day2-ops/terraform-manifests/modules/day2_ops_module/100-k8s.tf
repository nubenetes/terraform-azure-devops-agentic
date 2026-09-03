# https://kubernetes.io/docs/reference/access-authn-authz/rbac/
# https://www.mankier.com/1/kubectl-create-clusterrole
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
# https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/howto/access-control.md
# https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac

resource "kubernetes_namespace_v1" "appcore_client" {
  metadata {
    annotations = {
      name = "Enterprise"
    }
    labels = {
      app         = "ml"
      environment = local.environment
    }
    name = "Enterprise"
  }
}


resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    annotations = {
      name = "prometheus"
    }
    labels = {
      app         = "prometheus"
      environment = local.environment
    }
    name = "prometheus"
  }
}


######################################################################
# Cluster View permissions
######################################################################

# resource "kubernetes_cluster_role_v1" "developers" {
#   count = (var.environment != "pro") ? 1:0
#   metadata {
#     name = "cluster-view-poc"
#     labels = {
#       test = "ClusterViewRole"
#     }
#   }

#   rule {
#     api_groups = ["","apps","jobs","cronjobs"] # "" indicates the core API group
#     resources  = ["*"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding_v1" "cluster-view" {
#   metadata {
#     name      = "cluster-view"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     #name      = "cluster-view"
#     # https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles:~:text=Endpoints%22%20section.-,view,as%20any%20ServiceAccount%20in%20the%20namespace%20(a%20form%20of%20privilege%20escalation).,-Core%20component%20roles
#     name      = "view"
#   }
#   subject {
#     kind      = "Group"
#     #name      = data.azuread_group.aks_developers.id
#     name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#     #namespace = # (Optional) Namespace defines the namespace of the ServiceAccount to bind to. This value only applies to kind ServiceAccount
#   }
# }


resource "kubernetes_cluster_role_binding_v1" "cluster-view-developers" {
  metadata {
    name = "cluster-view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    #name      = "cluster-view"
    # https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles:~:text=Endpoints%22%20section.-,view,as%20any%20ServiceAccount%20in%20the%20namespace%20(a%20form%20of%20privilege%20escalation).,-Core%20component%20roles
    name = "view"
  }
  subject {
    kind      = "Group"
    name      = data.azuread_group.aks_developers.id
    api_group = "rbac.authorization.k8s.io"
  }
}


# resource "kubernetes_cluster_role_binding_v1" "cluster-view-developers2" {
#   metadata {
#     name      = "cluster-view-developers"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-view"
#     # https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles:~:text=Endpoints%22%20section.-,view,as%20any%20ServiceAccount%20in%20the%20namespace%20(a%20form%20of%20privilege%20escalation).,-Core%20component%20roles
#     #name      = "system:masters"
#   }
#   subject {
#     kind      = "Group"
#     name      = data.azuread_group.aks_developers.id
#     #name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#     #namespace = # (Optional) Namespace defines the namespace of the ServiceAccount to bind to. This value only applies to kind ServiceAccount
#   }
# }


# resource "kubernetes_cluster_role_binding_v1" "cluster-view-developers3" {
#   metadata {
#     name      = "cluster-view-developers2"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-view-poc"
#     # https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles:~:text=Endpoints%22%20section.-,view,as%20any%20ServiceAccount%20in%20the%20namespace%20(a%20form%20of%20privilege%20escalation).,-Core%20component%20roles
#     #name      = "system:masters"
#   }
#   subject {
#     kind      = "Group"
#     name      = data.azuread_group.aks_developers.id
#     #name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#     #namespace = # (Optional) Namespace defines the namespace of the ServiceAccount to bind to. This value only applies to kind ServiceAccount
#   }
# }





resource "kubernetes_cluster_role_binding_v1" "kubeapps-developers" {
  # https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac
  metadata {
    name = "kubeapps-developers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kubeapps:kubeapps:apprepositories-read"
    # https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles:~:text=Endpoints%22%20section.-,view,as%20any%20ServiceAccount%20in%20the%20namespace%20(a%20form%20of%20privilege%20escalation).,-Core%20component%20roles
    #name      = "system:masters"
  }
  subject {
    kind = "Group"
    name = data.azuread_group.aks_developers.id
    #name      = "system:masters"
    #api_group = "rbac.authorization.k8s.io"
    #namespace = # (Optional) Namespace defines the namespace of the ServiceAccount to bind to. This value only applies to kind ServiceAccount
  }
}



#########################################################################################################################################################################
# kubeapps
# https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/howto/access-control.md
# Read access to Applications within a namespace
# In order to list and view Applications in a namespace, use the default ClusterRole for viewing resources. Then you bind that cluster role to the service account.
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
#########################################################################################################################################################################

# resource "kubernetes_role_binding" "kubeapps_developers" {
#   metadata {
#     name      = "kubeapps-view"
#     namespace = "Enterprise"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "view" # this must match the name of the Role or ClusterRole you wish to bind to
#   }
#   subject {
#     kind      = "Group"
#     name      = data.azuread_group.aks_developers.id
#     api_group = "rbac.authorization.k8s.io"
#   }
# }









# resource "kubernetes_cluster_role_v1" "kubeapps_developers" {
#   metadata {
#     name = "kubeapps-cluster-view"
#     labels = {
#       test = "ClusterViewRole"
#     }
#   }

#   rule {
#     api_groups = [""] # "" indicates the core API group
#     resources  = ["*"]
#     verbs      = ["get", "list", "watch"]
#   }
# }


# resource "kubernetes_cluster_role_binding_v1" "kubeapps_developers" {
#   metadata {
#     name      = "kubeapps-cluster-view"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "kubeapps-cluster-view"
#     #name      = "kubeapps:kubeapps:apprepositories-read"
#   }
#   subject {
#     kind      = "Group"
#     name      = data.azuread_group.aks_developers.id
#     api_group = "rbac.authorization.k8s.io"
#   }
# }










# resource "kubernetes_cluster_role_binding_v1" "kubeapps_developers" {
#   metadata {
#     name      = "kubeapps-cluster-view"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "kubeapps:kubeapps:apprepositories-read"
#   }
#   subject {
#     kind      = "Group"
#     name      = data.azuread_group.aks_developers.id
#     api_group = "rbac.authorization.k8s.io"
#   }
# }





# resource "kubernetes_cluster_role_v1" "example" {
#   metadata {
#     name = "terraform-example"
#   }

#   aggregation_rule {
#     cluster_role_selectors {
#       match_labels = {
#         foo = "bar"
#       }

#       match_expressions {
#         key      = "environment"
#         operator = "In"
#         values   = ["non-exists-12345"]
#       }
#     }
#   }
# }