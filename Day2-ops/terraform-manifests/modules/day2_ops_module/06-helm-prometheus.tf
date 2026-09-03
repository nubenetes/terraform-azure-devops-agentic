# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider
# https://getbetterdevops.io/terraform-with-helm/

# Prometheus Helm Chart
# https://artifacthub.io/packages/helm/prometheus-community/prometheus

# nodeSelector:
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

# https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing

# https://kubernetes.io/docs/reference/access-authn-authz/authentication/
# https://medium.com/@mrbobbytables/kubernetes-day-2-operations-authn-authz-with-oidc-and-a-little-help-from-keycloak-de4ea1bdbbe
# https://medium.com/@int128/kubectl-with-openid-connect-43120b451672

######################################################################################################################################
# https://learn.microsoft.com/en-us/azure/active-directory/develop/scopes-oidc
# An example oauth2-proxy.cfg config file: https://github.com/oauth2-proxy/oauth2-proxy/blob/master/contrib/oauth2-proxy.cfg.example
# Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy: https://kristhecodingunicorn.com/post/k8s_nginx_oauth/
######################################################################################################################################

# resource "helm_release" "prometheus" {
#   name              = "prometheus"
#   repository        = "https://prometheus-community.github.io/helm-charts"
#   chart             = "prometheus"
#   version           = "23.0.0"
#   timeout           = 300 #1200
#   namespace         = "prometheus"
#   #verify            = true # (Optional) Verify the package before installing it.
#     # Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to false.
#   reset_values      = true # (Optional) When upgrading, reset the values to the ones built into the chart. Defaults to false.
#   force_update      = true # (Optional) Force resource update through delete/recreate if needed. Defaults to false.
#   recreate_pods     = true # (Optional) Perform pods restart during upgrade/rollback. Defaults to false.
#   cleanup_on_fail   = true # (Optional) Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to false.
#   #max_history       = 1    # (Optional) Maximum number of release versions stored per release. Defaults to 0 (no limit).
#   atomic            = false # (Optional) If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to false.
#   skip_crds         = false # (Optional) If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to false.
#   dependency_update = true # (Optional) Runs helm dependency update before installing the chart. Defaults to false.
#   #replace           = true # (Optional) Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to false.
#   #pass_credentials  = true # (Optional) Pass credentials to all domains. Defaults to false. # https://github.com/helm/helm/issues/9868
#   lint              = true # (Optional) Run the helm chart linter during the plan. Defaults to false.
#   create_namespace  = true # (Optional) Create the namespace if it does not yet exist. Defaults to false.

#   values = [
#     "${file("./helm/prometheus/values.yaml")}"
#   ]

#   # set {
#   #   name  = "nodeSelector"
#   #   value = "{ agentpool: appspool001, app: infra }"
#   # }

#   set {
#     name  = "server.ingress.enabled"
#     value = "true"
#   }
#   set {
#     name  = "server.ingress.annotations.kubernetes\\.azure\\.com/tls-secret-keyvault-uri"
#     value = "https://kv-wildcards-Enterprise-com.vault.azure.net/secrets/${local.secret_name_in_akv_with_wildcard_cert}/${data.azurerm_key_vault_secret.wildcards_Enterprise_com["${local.secret_name_in_akv_with_wildcard_cert}"].version}"
#   }

#   # set {
#   #   name  = "server.ingress.tls[0].secretName"
#   #   value = "prometheus-server-tls"
#   # }

#   set {
#     # using set for array of maps: https://github.com/hashicorp/terraform-provider-helm/issues/586
#     name  = "server.ingress.tls[0].hosts"
#     value = "{prometheus.${local.dns_child_zone}.enterprise.com}"
#   }
#   set {
#     name  = "server.ingress.hosts"
#     value = "{prometheus.${local.dns_child_zone}.enterprise.com}"
#   }
#   set {
#     name  = "server.ingress.ingressClassName"
#     value = "webapprouting.kubernetes.azure.com"
#   }
# }
