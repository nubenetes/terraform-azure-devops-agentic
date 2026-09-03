# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider
# https://getbetterdevops.io/terraform-with-helm/

# kubecost in AKS:
# https://blog.kubecost.com/blog/aks-cost/
# https://github.com/kubecost/cost-analyzer-helm-chart
# https://github.com/kubecost/cost-analyzer-helm-chart/tree/develop/cost-analyzer
# https://www.returngis.net/2022/05/saber-el-coste-de-tus-aplicaciones-en-kubernetes-con-kubecost-en-microsoft-azure/
# https://thenewstack.io/kubecost-monitor-kubernetes-costs-with-kubectl/
# https://www.infracloud.io/blogs/kubernetes-cost-reporting-using-kubecost/

# nodeSelector:
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/


#############################################################
# Disabled: we are using app-routing-system instead
# https://learn.microsoft.com/en-us/azure/aks/web-app-routing
# web_app_routing in 06-aks-cluster.tf
#############################################################

# resource "helm_release" "ingress-nginx" {
#   name             = "ingress-nginx"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   version          = "4.5.2"
#   timeout          = 1200
#   namespace        = "ingress-basic"
#   create_namespace = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

#   values = [
#     "${file("./helm/ingress-nginx/values.yaml")}"
#   ]

#   # set {
#   #   name  = "namespaceOverride"
#   #   value = "monitoring"
#   # }

#   set {
#     name  = "nodeSelector"
#     value = "{ agentpool: appspool001, app: infra }"
#   }

#   # set {
#   #   name  = "service.annotations.prometheus\\.io/port"
#   #   value = "9127"
#   #   type  = "string"
#   # }

# }