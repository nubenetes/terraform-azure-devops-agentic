# https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/key-vault/general/manage-with-cli2.md


# https://kv-enterprise-dev-app.vault.azure.net/
# kv-enterprise-dev-app

az account list --output table
az account set --subscription "enterprise Example-Dev-Subscription"

# get the current default subscription using show
az account show --output table

az keyvault show --name kv-enterprise-dev-app


az keyvault key list --vault-name kv-enterprise-dev-app


az keyvault secret list --vault-name kv-enterprise-dev-app




#PS > az keyvault secret list --vault-name kv-enterprise-dev-app
# [
#....
#   {
#     "attributes": {
#       "created": "2022-02-14T09:59:20+00:00",
#       "enabled": true,
#       "expires": null,
#       "notBefore": null,
#       "recoveryLevel": "Recoverable",
#       "updated": "2022-02-14T09:59:20+00:00"
#     },
#     "contentType": "Name",
#     "id": "https://kv-enterprise-dev-app.vault.azure.net/secrets/enterprise-sa",
#     "managed": null,
#     "name": "enterprise-sa",
#     "tags": {}
#   }
# ]


az keyvault secret show --name enterprise-sa --vault-name kv-enterprise-dev-app


# az keyvault secret show --name enterprise-sa --vault-name kv-enterprise-dev-app
# {
#   "attributes": {
#     "created": "2022-02-14T09:59:20+00:00",
#     "enabled": true,
#     "expires": null,
#     "notBefore": null,
#     "recoveryLevel": "Recoverable",
#     "updated": "2022-02-14T09:59:20+00:00"
#   },
#   "contentType": "Name",
#   "id": "https://kv-enterprise-dev-app.vault.azure.net/secrets/enterprise-sa/7268a8d2d6e14d36b605a3c7bf98fb8f",
#   "kid": null,
#   "managed": null,
#   "name": "enterprise-sa",
#   "tags": {},
#   "value": "dev-appenterprisesa"


# SA es dev-appenterprisesa




az keyvault secret show --name enterprise-mkey --vault-name kv-enterprise-dev-app




$SA = az keyvault secret show --name enterprise-sa --vault-name kv-enterprise-dev-app | ConvertFrom-Json
$SA.value

$saSecret = az keyvault secret show --name enterprise-mkey --vault-name kv-enterprise-dev-app | ConvertFrom-Json
$saSecret.value  

