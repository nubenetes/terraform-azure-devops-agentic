# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider
# https://getbetterdevops.io/terraform-with-helm/

# https://github.com/prometheus-community/helm-charts
# Helm must be installed to use the charts. Please refer to Helm's documentation to get started.
# Once Helm is set up properly, add the repo as follows:
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# You can then run helm search repo prometheus-community to see the charts.

# nodeSelector:
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

# https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "47.0.0"
  timeout          = 1200
  namespace        = "monitoring"
  create_namespace = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

  values = [
    "${file("./helm/kube-prometheus-stack/values.yaml")}"
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

  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }
  set {
    name  = "grafana.ingress.hosts"
    value = "{ grafana.${local.dns_child_zone}.enterprise.com }"
    #type  = "string"
  }
  set {
    name  = "grafana.ingress.ingressClassName"
    value = "webapprouting.kubernetes.azure.com"
  }
  set {
    # using set for array of maps: https://github.com/hashicorp/terraform-provider-helm/issues/586
    name  = "grafana.ingress.tls[0].secretName"
    value = "grafana-general-tls"
  }
  set {
    # using set for array of maps: https://github.com/hashicorp/terraform-provider-helm/issues/586
    name  = "grafana.ingress.tls[0].hosts"
    value = "{grafana.${local.dns_child_zone}.enterprise.com}"
  }
  set {
    name  = "grafana.grafana\\.ini.server.root_url"
    value = "https://grafana.${local.dns_child_zone}.enterprise.com/"
    type  = "string"
  }
  set {
    name  = "grafana.grafana\\.ini.auth\\.azuread.client_id"
    value = azuread_application.grafana_login.application_id
    type  = "string"
  }
  set {
    name  = "grafana.grafana\\.ini.auth\\.azuread.client_secret"
    value = azuread_application_password.grafana_login.value
    type  = "string"
  }
}