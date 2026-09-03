# https://skooner.io/install/#installing-skooner-on-kubernetes-cluster
# https://github.com/skooner-k8s/skooner
# https://learn.microsoft.com/en-us/azure/aks/web-app-routing
resource "kubectl_manifest" "skooner_namespace" {
  yaml_body = <<YAML
kind: Namespace
apiVersion: v1
metadata:
  name: skooner
  annotations:
    name: skooner
  labels:
    k8s-app: skooner
YAML
}


resource "kubectl_manifest" "skooner_deployment" {
  yaml_body = <<YAML
kind: Deployment
apiVersion: apps/v1
metadata:
  name: skooner
  namespace: skooner
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: skooner
  template:
    metadata:
      labels:
        k8s-app: skooner
    spec:
      containers:
      - name: skooner
        image: ghcr.io/skooner-k8s/skooner:stable
        ports:
        - containerPort: 4654
        livenessProbe:
          httpGet:
            scheme: HTTP
            path: /
            port: 4654
          initialDelaySeconds: 30
          timeoutSeconds: 30
        env:
        - name: OIDC_URL
          valueFrom:
            secretKeyRef:
              name: skooner
              key: url
        - name: OIDC_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: skooner
              key: id
        - name: OIDC_SECRET
          valueFrom:
            secretKeyRef:
              name: skooner
              key: secret
      nodeSelector:
        agentpool: appspool001
        app: infra
YAML
  depends_on = [
    kubectl_manifest.skooner_namespace,
    #kubectl_manifest.skooner_oidc_secret,
    kubernetes_secret_v1.skooner,
  ]
}

resource "kubectl_manifest" "skooner_service" {
  yaml_body = <<YAML
kind: Service
apiVersion: v1
metadata:
  name: skooner
  namespace: skooner
spec:
  ports:
    - port: 80
      targetPort: 4654
  selector:
    k8s-app: skooner
YAML
  depends_on = [
    kubectl_manifest.skooner_namespace,
    kubectl_manifest.skooner_deployment,
  ]
}

# az keyvault certificate show --vault-name kv-azuredevops-library2 -n skooner-deng --query "id" --output tsv
# az keyvault secret show --vault-name kv-wildcards-Enterprise-com -n cert-wildcard-deng-Enterprise-com00000000-0000-0000-0000-000000000000 --query "id" --output tsv
# az keyvault certificate show --vault-name kv-wildcards-Enterprise-com -n skooner-deng --query "id" --output tsv
# az keyvault certificate show --vault-name kv-wildcards-Enterprise-com -n cert-wildcard-Enterprise-deng --query "id" --output tsv

# Manually grant 'Key Vault Reader" RBAC permissions on 'kv-wildcards-Enterprise-com' to 'webapprouting-aks-dneeng' service principal

##########################################################################
# https://learn.microsoft.com/en-us/azure/aks/web-app-routing
# https://github.com/kubernetes-sigs/external-dns
# NGINX Ingress Controller: https://kubernetes.github.io/ingress-nginx/ -> THIS IS ANOTHER ingressClassName !!! (annotations are not valid in webapprouting.kubernetes.azure.com ingressClass)
# https://kubernetes.io/docs/concepts/services-networking/ingress/
# https://kubernetes.github.io/ingress-nginx/examples/tls-termination/
# https://github.com/Azure-Samples/azure-opensource-labs/tree/main/cloud-native/aks-webapp-routing
# https://azure.github.io/Cloud-Native/cnny-2023/fundamental
# Ingress Controllers in AKS: https://learn.microsoft.com/en-us/azure/aks/ingress-basic?%3FWT.mc_id=containers-84290-pauyu&tabs=azure-cli
# az aks show -n aks-dneeng -g rg-sharedinfra-aks-dneeng --query ingressProfile
##########################################################################

#######################################################################################################################
# Azure Key Vault to Kubernetes (akv2k8s for short) makes it simple and secure to use Azure Key Vault secrets,
# keys and certificates in Kubernetes.
# https://github.com/sparebankenvest/azure-key-vault-to-kubernetes
#######################################################################################################################
resource "kubectl_manifest" "skooner_ingress" {
  yaml_body = <<YAML
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: skooner
  namespace: skooner
  annotations:
    #kubernetes.azure.com/tls-cert-keyvault-uri: "https://kv-azuredevops-library2.vault.azure.net/certificates/skooner-deng/bafdb264ae7a47f2bb6f7f3d9125279b"
    #kubernetes.azure.com/tls-cert-keyvault-uri: "https://kv-wildcards-Enterprise-com.vault.azure.net/certificates/cert-wildcard-Enterprise-${local.dns_child_zone}/${data.azurerm_key_vault_certificate.wildcards_Enterprise_com.version}"
    kubernetes.azure.com/tls-secret-keyvault-uri: "https://kv-wildcards-Enterprise-com.vault.azure.net/secrets/${local.secret_name_in_akv_with_wildcard_cert}/${data.azurerm_key_vault_secret.wildcards_Enterprise_com["${local.secret_name_in_akv_with_wildcard_cert}"].version}"
    #kubernetes.azure.com/tls-secret-name:
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  rules:
  - host: skooner.${local.dns_child_zone}.enterprise.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: skooner
            port:
              number: 80
        #pathType: ImplementationSpecific
        pathType: Prefix
  tls:
  - hosts:
    - skooner.${local.dns_child_zone}.enterprise.com
    secretName: keyvault-aks-skooner-${local.dns_child_zone} # secretName is the name of the secret that going to be generated to store the certificate. This is the certificate that's going to be presented in the browser.
YAML
  depends_on = [
    kubectl_manifest.skooner_namespace,
    kubectl_manifest.skooner_service,
  ]
}


# https://kubernetes.io/docs/reference/access-authn-authz/authentication/
# https://medium.com/@mrbobbytables/kubernetes-day-2-operations-authn-authz-with-oidc-and-a-little-help-from-keycloak-de4ea1bdbbe
# https://medium.com/@int128/kubectl-with-openid-connect-43120b451672
# resource "kubectl_manifest" "skooner_oidc_secret" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: Secret
# metadata:
#   name: skooner
#   namespace: skooner
# type: Opaque
# stringData:
# #data:
#   id: ${azuread_application.skooner_login.application_id}
#   secret: ${azuread_application_password.skooner_login.value}
#   url: "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
# YAML
# depends_on = [
#   kubectl_manifest.skooner_namespace,
#   azuread_application.skooner_login,
#   azuread_application_password.skooner_login,
#   ]
# }



resource "kubernetes_secret_v1" "skooner" {
  metadata {
    name      = "skooner"
    namespace = "skooner"
  }

  data = {
    id     = azuread_application.skooner_login.application_id
    secret = azuread_application_password.skooner_login.value
    url    = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
  }
  type = "Opaque"
}
