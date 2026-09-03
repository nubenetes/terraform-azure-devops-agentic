# https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs
# Key Vault Azure role-based access control permission model:
# - Application Gateway supports certificates referenced in Key Vault via the Role-based access control permission model. The first few steps to reference the Key Vault must be completed via **ARM template, Bicep, CLI, or PowerShell.**
# - Specifying Azure Key Vault certificates that are subject to the role-based access control permission model is not supported via the portal.
# - In this example, we’ll use PowerShell to reference a new Key Vault secret.
#     ```
#     # Get the Application Gateway we want to modify
#     $appgw = Get-AzApplicationGateway -Name MyApplicationGateway -ResourceGroupName MyResourceGroup
#     # Specify the resource id to the user assigned managed identity - This can be found by going to the properties of the managed identity
#     Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity"
#     # Get the secret ID from Key Vault
#     $secret = Get-AzKeyVaultSecret -VaultName "MyKeyVault" -Name "CertificateName"
#     $secretId = $secret.Id.Replace($secret.Version, "") # Remove the secret version so AppGW will use the latest version in future syncs
#     # Specify the secret ID from Key Vault 
#     Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $secret.Name
#     # Commit the changes to the Application Gateway
#     Set-AzApplicationGateway -ApplicationGateway $appgw
#     ```
# - Once the commands have been executed, you can navigate to your Application Gateway in the Azure portal and select the Listeners tab. Click Add Listener (or select an existing) and specify the Protocol to HTTPS.
# - Under Choose a certificate select the certificate named in the previous steps. Once selected, select Add (if creating) or Save (if editing) to apply the referenced Key Vault certificate to the listener.

$MyApplicationGateway='agw-appcore-myclient-dev'
$MyResourceGroup='rg-appcore-myclient-dev'
$MyManagedIdentity='id-kv-appcore-myclient-dev'
$MyKeyVaultName='kv-appcore-myclientdev'
$MyCertificateName='cert-order-myclient-dev'
$MyAzureSubscription='00000000-0000-0000-0000-000000000000'

#################
# Start of script
#################

# Get the Application Gateway we want to modify
write-host "1. Get-AzApplicationGateway"
""
$appgw = Get-AzApplicationGateway -Name $MyApplicationGateway -ResourceGroupName $MyResourceGroup
$appgw
""
""
write-host "2. Set-AzApplicationGatewayIdentity"
""
# Specify the resource id to the user assigned managed identity - This can be found by going to the properties of the managed identity
Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId "/subscriptions/$MyAzureSubscription/resourceGroups/$MyResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$MyManagedIdentity"
""
""
write-host "3. Get-AzKeyVaultSecret"
""
# Get the secret ID from Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $MyKeyVaultName -Name $MyCertificateName
$secret
""
""
write-host "4. secret.Id.Replace"
""
$secretId = $secret.Id.Replace($secret.Version, "") # Remove the secret version so AppGW will use the latest version in future syncs
#$secretId = $secret.Id
$secretId
""
""
write-host "5. Add-AzApplicationGatewaySslCertificate"
""
# Specify the secret ID from Key Vault 
Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $secret.Name
""
""
write-host "6. Set-AzApplicationGateway"
""
# Commit the changes to the Application Gateway
Set-AzApplicationGateway -ApplicationGateway $appgw
""
""