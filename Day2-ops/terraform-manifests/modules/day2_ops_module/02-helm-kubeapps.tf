# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider
# https://getbetterdevops.io/terraform-with-helm/
# https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/howto/OIDC/OAuth2OIDC-oauth2-proxy.md#using-the-chart
# https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/howto/OIDC/using-an-OIDC-provider-with-pinniped.md
# https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/howto/OIDC/OAuth2OIDC-azure-active-directory.md

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

######################################################################################################################################
# https://learn.microsoft.com/en-us/azure/active-directory/develop/scopes-oidc
# An example oauth2-proxy.cfg config file: https://github.com/oauth2-proxy/oauth2-proxy/blob/master/contrib/oauth2-proxy.cfg.example
# Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy: https://kristhecodingunicorn.com/post/k8s_nginx_oauth/
######################################################################################################################################

resource "helm_release" "kubeapps" {
  name       = "kubeapps"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"
  version    = "12.4.4"
  timeout    = 1200
  namespace  = "kubeapps" #"default"
  #verify            = true # (Optional) Verify the package before installing it.
  # Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to false.
  reset_values    = true # (Optional) When upgrading, reset the values to the ones built into the chart. Defaults to false.
  force_update    = true # (Optional) Force resource update through delete/recreate if needed. Defaults to false.
  recreate_pods   = true # (Optional) Perform pods restart during upgrade/rollback. Defaults to false.
  cleanup_on_fail = true # (Optional) Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to false.
  #max_history       = 1    # (Optional) Maximum number of release versions stored per release. Defaults to 0 (no limit).
  atomic            = false # (Optional) If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to false.
  skip_crds         = false # (Optional) If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to false.
  dependency_update = true  # (Optional) Runs helm dependency update before installing the chart. Defaults to false.
  #replace           = true # (Optional) Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to false.
  #pass_credentials  = true # (Optional) Pass credentials to all domains. Defaults to false. # https://github.com/helm/helm/issues/9868
  lint             = true # (Optional) Run the helm chart linter during the plan. Defaults to false.
  create_namespace = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

  values = [
    "${file("./helm/kubeapps/values.yaml")}"
  ]

  # set {
  #   name  = "namespaceOverride"
  #   value = "monitoring"
  # }

  # set {
  #   mame  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
  #   value = "nginx"
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
    name  = "ingress.enabled"
    value = "true"
    #type  = "auto"
  }
  set {
    name  = "ingress.tls"
    value = "true"
    #type  = "auto"
  }
  set {
    name  = "ingress.selfSigned"
    value = "true"
    #type  = "auto"
  }
  set {
    name  = "ingress.hostname"
    value = "kubeapps.${local.dns_child_zone}.enterprise.com"
    #type  = "string"
  }
  set {
    name  = "ingress.ingressClassName"
    value = "webapprouting.kubernetes.azure.com"
    #type  = "string"
  }

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
  #   name  = "frontend.proxypassAccessTokenAsBearer"
  #   value = true # required to pass the access_token instead of the id_token
  #   type  = "auto"
  #   # Use access_token as the Bearer when talking to the k8s api server
  #   # NOTE: Some K8s distributions such as GKE requires it
  # }
  set {
    name  = "authProxy.enabled"
    value = true
    type  = "auto"
  }
  set {
    # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
    name  = "authProxy.provider"
    value = "azure" #"oidc"
    type  = "string"
  }
  set {
    name  = "authProxy.clientID"
    value = azuread_application.kubeapps_login.application_id
    type  = "string"
  }
  set {
    name  = "authProxy.clientSecret"
    value = azuread_application_password.kubeapps_login.value
    type  = "string"
  }
  set {
    # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/#generating-a-cookie-secret
    name  = "authProxy.cookieSecret"
    value = random_password.cookie_secret.result
    type  = "string"
  }
  # set {
  #   name  = "authProxy.scope"
  #   value = "openid email"    # https://learn.microsoft.com/en-us/azure/active-directory/develop/scopes-oidc
  #   type  = "string"
  # }
  # set {
  #   name  = "authProxy.scope"
  #   value = "openid email 00000000-0000-0000-0000-000000000000/user.read"
  #   type  = "string"
  #   # AADSTS70011: The provided request must include a 'scope' input parameter. The provided value for the input parameter 'scope' is not valid.
  #   # The scope openid email 00000000-0000-0000-0000-000000000000/user.read https://graph.microsoft.com/.default is not valid. .default scope can't be combined with resource-specific scopes.
  # }
  set {
    # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/
    # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
    name = "authProxy.extraFlags"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email,--resource=00000000-0000-0000-0000-000000000000/.default}" # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
    # OK
    value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--resource=00000000-0000-0000-0000-000000000000/.default,--azure-tenant=ac1b4-8cf-ffda-4abf-8176-8d5f00c1a643}" # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
    # NOK:
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email 00000000-0000-0000-0000-000000000000/user.read}" # required for azure, exactly this string without modification
    # AADSTS70011: The provided request must include a 'scope' input parameter. The provided value for the input parameter 'scope' is not valid. The scope openid email 00000000-0000-0000-0000-000000000000/user.read https://graph.microsoft.com/.default is not valid. .default scope can't be combined with resource-specific scopes.
    # NOK:
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email 00000000-0000-0000-0000-000000000000/user.read,--resource=00000000-0000-0000-0000-000000000000/.default}" # required for azure, exactly this string without modification
    # AADSTS70011: The provided request must include a 'scope' input parameter. The provided value for the input parameter 'scope' is not valid. The scope openid email 00000000-0000-0000-0000-000000000000/user.read https://graph.microsoft.com/.default is not valid. .default scope can't be combined with resource-specific scopes.

    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--session-cookie-minimal}" # CrashLookBackOff error
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--show-debug-on-error}" # show detailed error information on error pages (WARNING: this may contain sensitive information - do not use in production)
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--show-debug-on-error,--ssl-insecure-skip-verify,--ssl-upstream-insecure-skip-verify}"
    #
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--show-debug-on-error,--cookie-secure=false}" # option to enable the cookie being set over an insecure connection for local development only = redirect_uri=http://myapp/oauth2/callback
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--session-cookie-minimal,--show-debug-on-error}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--session-cookie-minimal}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--azure-tenant=00000000-0000-0000-0000-000000000000}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email 00000000-0000-0000-0000-000000000000/user.read}"
    #
    #value = "{--redirect-url=https://kubeapps.deng.enterprise.com/oauth2/callback,--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email 00000000-0000-0000-0000-000000000000/user.read,--set-authorization-header=true,--set-xauthrequest=true,--insecure-oidc-allow-unverified-email=true}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--azure-tenant=00000000-0000-0000-0000-000000000000}"
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--azure-tenant=00000000-0000-0000-0000-000000000000,oidc_groups_claim=roles,--insecure-oidc-allow-unverified-email=true}" # https://github.com/oauth2-proxy/oauth2-proxy/issues/1680
    #value = "{--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0}"
    #value = "{-ssl-insecure-skip-verify,--cookie-secure=false,--oidc-issuer-url=https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0,--scope=openid email 00000000-0000-0000-0000-000000000000/user.read}"
    # NOTE: If the identity provider is deployed with a self-signed certificate (which may be the case for Keycloak or Dex) you will need to deactivate the TLS and cookie verification. For doing so you can add the flags -ssl-insecure-skip-verify and --cookie-secure=false to the deployment above.
    # You can find more options for oauth2-proxy at: https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/
    type = "string"
  }
  ################################################################################################################################################################################################
  # NGINX Ingress Controller: https://kubernetes.github.io/ingress-nginx/ -> THIS IS ANOTHER ingressClassName !!! (annotations are not valid in webapprouting.kubernetes.azure.com ingressClass)
  # https://azure.github.io/Cloud-Native/cnny-2023/fundamentals-day-2/
  # https://github.com/Azure-Samples/azure-opensource-labs/tree/main/cloud-native/aks-webapp-routing
  # Ingress Controllers in AKS: https://learn.microsoft.com/en-us/azure/aks/ingress-basic?%3FWT.mc_id=containers-84290-pauyu&tabs=azure-cli
  # az aks show -n aks-dneeng -g rg-sharedinfra-aks-dneeng --query ingressProfile
  ################################################################################################################################################################################################
  set {
    # https://kubeapps.dev/docs/latest/project/chart-readme/#how-to-configure-kubeapps-with-ingress
    # https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/howto/OIDC/OAuth2OIDC-azure-active-directory.md
    # Note: If you are using an nginx reverse proxy to get to kubeapps you might need to increase the proxy_buffer_size as Azure's session store is too large for nginx. Similar changes might also be required for other reverse proxies.
    # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#azure-auth-provider
    # When using the Azure Auth provider with nginx and the cookie session store you may find the cookie is too large and doesn't get passed through correctly. Increasing the proxy_buffer_size in nginx or implementing the redis session storage should resolve this.
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-buffer-size"
    value = "32k" #"128k" #"16k" #"8k"
    type  = "string"
    # Trying to fix the signing-in loop, probably due to cookies not being properly set up.
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-read-timeout"
    value = "600"
    type  = "string"
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/proxy-buffers"
    value = "4"
    type  = "string"
  }
  set {
    #https://github.com/vmware-tanzu/kubeapps/blob/main/site/content/docs/latest/howto/OIDC/OAuth2OIDC-oauth2-proxy.md
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/connection-proxy-header"
    value = "keep-alive"
    type  = "string"
  }
  # set {
  #   name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
  #   value = "https://kubeapps.${local.environment}.enterprise.com/oauth2/start"
  #   type  = "string"
  # }
  # set {
  #   name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-signin"
  #   value = "https://kubeapps.${local.environment}.enterprise.com/oauth2/start?rd=$escaped_request_uri"
  #   type  = "string"
  # }
  # set {
  #   name  = "pinnipedProxy.enabled"
  #   value = true # Pinniped Proxy configuration for converting user OIDC tokens to k8s client authorization certs
  #   type  = "auto"
  # }

  # set {
  #   name  = "diagnosticMode.enabled"
  #   value = true
  #   type  = "auto"
  # }
}

# When using the Azure Auth provider with nginx and the cookie session store you may find the cookie is too large and doesn't get passed through correctly. Increasing the proxy_buffer_size in nginx or implementing the redis session storage should resolve this.
# https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#proxy-buffer-size
# Proxy buffer size¶
# Sets the size of the buffer proxy_buffer_size used for reading the first part of the response received from the proxied server. By default proxy buffer size is set as "4k"
# To configure this setting globally, set proxy-buffer-size in NGINX ConfigMap. To use custom values in an Ingress rule, define this annotation:
# nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"
#
# https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md
# https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md#proxy-buffer-size



# https://github.com/vmware-tanzu/kubeapps/blob/v2.6.4/site/content/docs/latest/howto/OIDC/OAuth2OIDC-oauth2-proxy.md#using-the-chart
# Example 1: Using the OIDC provider
# This example uses oauth2-proxy's generic OIDC provider with Google, but is applicable to any OIDC provider such as Keycloak, Dex, Okta or Azure Active Directory etc. Note that the issuer url is passed as an additional flag here, together with an option to enable the cookie being set over an insecure connection for local development only:
# helm install kubeapps bitnami/kubeapps \
#   --namespace kubeapps \
#   --set authProxy.enabled=true \
#   --set authProxy.provider=oidc \
#   --set authProxy.clientID=my-client-id.apps.googleusercontent.com \
#   --set authProxy.clientSecret=my-client-secret \
#   --set authProxy.cookieSecret=$(echo "not-good-secret" | base64) \
#   --set authProxy.extraFlags="{--cookie-secure=false,--oidc-issuer-url=https://accounts.google.com}" \


# kubeapps oauth2 oidc to azure giving 500 Internal Error
# https://github.com/vmware-tanzu/kubeapps/issues/4824
# Thanks for the information, to start debugging we'd need to know which is the cause of this 500 error.
# What's the output of kubectl -n kubeapps  logs deployment/kubeapps --all-containers ?




# resource "kubectl_manifest" "serviceAccount" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: kubeapps-operator
#   namespace: default
# YAML
# }



# resource "kubectl_manifest" "clusterRoleBinding" {
#   yaml_body = <<YAML
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: kubeapps-operator
# subjects:
#   - kind: ServiceAccount
#     name: kubeapps-operator
#     namespace: default
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# YAML
# }



# https://github.com/vmware-tanzu/kubeapps/issues/6269
resource "kubernetes_role_binding_v1" "kubeapps" {
  metadata {
    name      = "kubeapps-admin"
    namespace = "kubeapps"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "admin"
  }
  # subject {
  #   kind      = "User"
  #   name      = "admin"
  #   api_group = "rbac.authorization.k8s.io"
  # }
  subject {
    kind      = "Group"
    name      = data.azuread_group.aks_developers.id
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [helm_release.kubeapps]
}


/*
127.0.0.1:43142 - b5b360fc2b049d0c770ef29a5474add5 - - [2000/01/01 16:20:41] kubeapps.deng.enterprise.com GET / "/" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 206 0.003
127.0.0.1:43142 - 41a4f7eeb3832a6b2b52124a414b9907 - - [2000/01/01 16:20:41] kubeapps.deng.enterprise.com GET / "/static/css/main.5c0cb017.css" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 242582 0.055
127.0.0.1:43146 - 2ebe2b440733fd65ff9a41b48a011dec - - [2000/01/01 16:20:41] kubeapps.deng.enterprise.com GET / "/custom_locale.json" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 2 0.004
127.0.0.1:43146 - a68bc4c1d30c45ae5eb006ce8559dddc - - [2000/01/01 16:20:42] kubeapps.deng.enterprise.com GET / "/config.json" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 679 0.001
127.0.0.1:43150 - 10f8eae0b13b649b60ffcac7f81ad49c - - [2000/01/01 16:20:42] kubeapps.deng.enterprise.com GET / "/clr-ui.min.css" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 162193 0.053
127.0.0.1:43146 - 61b581718ad4e82835c1de2cc6528b09 - - [2000/01/01 16:20:43] kubeapps.deng.enterprise.com GET / "/static/media/ClarityCity-SemiBold.508f08b507bb08382c2e.woff2" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 17252 0.002
[2000/01/01 16:20:45] [oauthproxy.go:959] No valid authentication in request. Initiating login.
127.0.0.1:43150 - a167b2c0e6bba0cb570c165ad128ee1d - - [2000/01/01 16:20:45] kubeapps.deng.enterprise.com GET - "/clr-ui.min.css.map" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 403 8507 0.000
127.0.0.1:43142 - 2b496c3c4b34ab8039a90f25f0a09586 - - [2000/01/01 16:20:41] kubeapps.deng.enterprise.com GET / "/static/js/main.752354c9.js.map" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 200 23554580 3.897
[2000/01/01 16:20:49] [oauthproxy.go:830] Error creating session during OAuth2 callback: unable to get groups from Microsoft Graph: unable to unmarshal Microsoft Graph response: unexpected status "403": {"error":{"code":"Authorization_RequestDenied","message":"Insufficient privileges to complete the operation.","innerError":{"date":"2023-04-14T16:20:49","request-id":"00000000-0000-0000-0000-000000000000","client-request-id":"00000000-0000-0000-0000-000000000000"}}}
127.0.0.1:43142 - 8ff6d1ea964a4840c5284ac7065c76b1 - - [2000/01/01 16:20:49] kubeapps.deng.enterprise.com GET - "/oauth2/callback?code=0.ASAAz0gbrNr_v0qBdo1fAMGmQ499byV0-ddDgMSUuZJoFPAgAP0.AgABAAIAAAD--DLA3VO7QrddgJg7WevrAgDs_wUA9P9LpBtnwjf5PoV2QfBicmJFMB4TnMmcDnrO8J6xPAYb3FWY3Uv6FrrSV465pxhIetWRiJtvpBur55W2tJTlA-2rVgMGrb1Cp_VTqAKNCLPaUB46ZhWOiqdMIcoLTvQVBQrvc_PuLRp2nVHB_RND9zZDE7JFbai6wT6zJj9KMVo-YPtMYbVRNXOuhRBWOqHVhSgehTVzHiG86-jOM1wTQdy1KaoW-cPDCtkmhNnTJfuR9LylCr_1E-D8Wc-oIzCQ-3UpttDAY3wXgBUkgh66Tp83-lhURPWMXlbLPoVMrNa2x2MVoIMBq-pH66eQKA6kSoGJCR-db_msk94v4PzdTji3X-E1e-3yFgeJzohh05Q66LusNgYTrgNAopcR6ASBWQxgHVhPkGNrxRT28TbMVmDOl7nFpHuiEMyJtdUr_1l4mbrKydvj4zH3Igb3NAXrNKSNrPozPBoucPhzXtQZDqEdYFZ4DCzvoYKtCZ4uOqfYv0JHQuBh_DtrLKZ6x61zO2degi5C7BxWN0gWXycSDPm-lboFE6yGRmvlLyappcWFRYfVyeEG9DVswmAG-gJnrhT118LxeRrPCBLllJ1lpo1voc2FCUyR47y4Et1i19F4zzJwbFBELwV2hRL6iCGt7mfLL4ZMy-hsl1tL-re_W9e-kqwyb7FvQit98SBZz8Iex7tsZGj-bC_do3536e0rDWsLnlCB8RVRGFHo4aSPxXjCsBK8_lSmhNl_3ykz-63nCvm24Wq9eBfUBy2Vj4xTZ2gtOfHVXqTfM&state=BWsKQmdCeOFpK7XLUofx7HSLAgxL2hpA_VMV6xVRdyc%3a%2f&session_state=00000000-0000-0000-0000-000000000000" HTTP/1.1 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.1 Safari/537.36" 500 2837 0.719
*/