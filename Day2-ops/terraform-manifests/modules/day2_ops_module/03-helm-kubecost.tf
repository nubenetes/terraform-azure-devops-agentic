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

resource "helm_release" "kubecost" {
  count            = 0
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  chart            = "cost-analyzer"
  version          = "1.101.3"
  timeout          = 1200
  namespace        = "kubecost"
  create_namespace = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

  values = [
    "${file("./helm/kubecost/values.yaml")}"
  ]

  # set {
  #   name  = "namespaceOverride"
  #   value = "monitoring"
  # }

  set {
    name  = "nodeSelector"
    value = "{ agentpool: appspool001, app: infra }"
  }

  # set {
  #   name  = "service.annotations.prometheus\\.io/port"
  #   value = "9127"
  #   type  = "string"
  # }

}