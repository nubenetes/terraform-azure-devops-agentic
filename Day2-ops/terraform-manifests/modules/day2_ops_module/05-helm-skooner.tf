# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider
# https://getbetterdevops.io/terraform-with-helm/

# kubeapps helm chart:
# https://kubeapps.dev/docs/latest/tutorials/getting-started/#step-1-install-kubeapps

# nodeSelector:
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

# https://github.com/vmware-tanzu/kubeapps/blob/main/chart/kubeapps/README.md
# https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/tutorials/using-an-OIDC-provider.md

# https://bitnami.com/stack/kubeapps/helm
# helm search repo bitnami/kubeapps --versions

# https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing

# https://kubernetes.io/docs/reference/access-authn-authz/authentication/
# https://medium.com/@mrbobbytables/kubernetes-day-2-operations-authn-authz-with-oidc-and-a-little-help-from-keycloak-de4ea1bdbbe
# https://medium.com/@int128/kubectl-with-openid-connect-43120b451672

# https://skooner.io/install/#installing-skooner-on-kubernetes-cluster
# https://github.com/skooner-k8s/skooner
# https://kubernetes.io/docs/reference/access-authn-authz/authentication/
# https://medium.com/@mrbobbytables/kubernetes-day-2-operations-authn-authz-with-oidc-and-a-little-help-from-keycloak-de4ea1bdbbe
# https://medium.com/@int128/kubectl-with-openid-connect-43120b451672
# Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy:https://kristhecodingunicorn.com/post/k8s_nginx_oauth/

resource "helm_release" "skooner" {
  count            = 0
  name             = "skooner"
  repository       = "https://christianknell.github.io/helm-charts"
  chart            = "skooner"
  version          = "0.0.6"
  timeout          = 1200
  namespace        = "skooner"
  create_namespace = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

  values = [
    "${file("./helm/skooner/values.yaml")}"
  ]

  # set {
  #   name  = "namespaceOverride"
  #   value = "monitoring"
  # }

  # set {
  #   mame  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
  #   value = "nginx"
  # }

  # set {
  #   name  = "nodeSelector"
  #   value = "{ agentpool: appspool001, app: infra }"
  #   type  = "auto"
  # }
  # set {
  #   name  = "service.annotations.prometheus\\.io/port"
  #   value = "9127"
  #   type  = "string"
  # }
  # set {
  #   name  = "ingress.enabled"
  #   value = "true"
  #   #type  = "auto"
  # }
  # set {
  #   name  = "ingress.hosts[0].host"
  #   value = "kubeapps.${local.environment}.enterprise.com"
  #   #type  = "auto"
  # }
  # set {
  #   name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
  #   value = "webapprouting.kubernetes.azure.com"
  #   type  = "auto"
  # }
  # set {
  #   name  = "ingress.annotations.kubernetes\\.io/tls-acme"
  #   value = "true"
  #   type  = "auto"
  # }
  # set {
  #   name  = "serviceAccount.create"
  #   value = "false"
  #   #type  = "auto"
  # }
  # Configuring Azure Active Directory as an OIDC provider
  # https://kubeapps.dev/docs/latest/howto/oidc/oauth2oidc-azure-active-directory/
  # https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/tutorials/using-an-OIDC-provider.md
  # https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/howto/OIDC/OAuth2OIDC-oauth2-proxy.md#using-the-chart
  # https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/howto/access-control.md

  ##################################################################################################################
  # OAuth Provider Configuration:
  # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/
  # https://github.com/oauth2-proxy/oauth2-proxy/releases/tag/v7.4.0
  # https://github.com/oauth2-proxy/oauth2-proxy/blob/master/docs/docs/configuration/auth.md#azure-auth-provider
  ##################################################################################################################
  # set {
  #   name  = "oidc.provider.oidcUrl"
  #   value = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
  #   type  = "auto"
  # }
  # set {
  #   name  = "oidc.enabled"
  #   value = "true"
  #   #type  = "auto"
  # }
  set {
    name  = "oidc.secret.clientID"
    value = azuread_application.skooner_login.application_id
    #type  = "auto"
  }
  set {
    name  = "oidc.secret.clientSecret"
    value = azuread_application_password.skooner_login.value
    #type  = "auto"
  }
}
