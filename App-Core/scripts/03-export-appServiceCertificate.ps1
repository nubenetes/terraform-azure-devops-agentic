#################################################################################################################################################################################################
# The below script is based on the following references:
# https://azure.github.io/AppService/2000/01/01/Creating-a-local-PFX-copy-of-App-Service-Certificate.html
# https://learn.microsoft.com/en-us/answers/questions/366519/unable-to-export-app-service-certificate.html
#       - The SecretValueText has been deprecated since Az verson 3.0.0
#       - Resolution: After modifying the script you can successfully get the SecretValueText. Below is the full script for the reference
# GoDaddy Certificate Chain - G2: https://certs.godaddy.com/repository
#################################################################################################################################################################################################

# https://learn.microsoft.com/en-us/answers/questions/563809/creating-a-local-pfx-copy-of-app-service-certifica.html
# https://dotnetdevlife.wordpress.com/2000/01/01/export-azure-app-service-certificate-upload-to-azure-app-service-website/#:~:text=1.%20Go%20to%20App%20Service%20Certificate%20in%20Azure,NOTE%3A%20this%20pfx%20file%20has%20empty%20password%205.
# https://learn.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest#az_keyvault_secret_download
# https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/key-vault/certificates/how-to-export-certificate.md#powershell

#################################################################################################################################################################################################
# Get cert and save it as pfx
# This command gets the certificate named `$certName` from the key vault named `$vaultName`. These commands access secret `$certName` and then save the content as a pfx file.
# https://learn.microsoft.com/en-us/powershell/module/az.keyvault/Get-AzKeyVaultCertificate?view=azps-9.0.1
#
# Get-AzKeyVaultCertificate -VaultName "kv-wildcards-Enterprise-com" -Name "cert-wildcard-deng-Enterprise-com" -Debug
# Get-AzKeyVaultCertificate -VaultName "kv-wildcards-Enterprise-com" -Name "cert-wildcard-Enterprise-deng" -Debug
#
# https://kv-wildcards-Enterprise-com.vault.azure.net/certificates/cert-wildcard-Enterprise-deng/c75c68d593c24901b89050a6a870d8e8
# issue - breaking changes in the cmdlet 'Get-AzKeyVaultSecret': https://github.com/MicrosoftDocs/azure-docs/issues/64538
# Downloading as certificate means getting the public portion. If you want both the private key and public metadata then you can download it as secret.
#    https://learn.microsoft.com/en-us/azure/key-vault/certificates/how-to-export-certificate
#    This command exports the entire chain of certificates with private key (i.e. the same as it was imported). The certificate is password protected.
#################################################################################################################################################################################################

#################################################################################################################################################################################################
# Enable debug logging in Az powershell (you will see all the MSAL/OAuth2.0 Workflow within your az cmdlets):
# https://learn.microsoft.com/en-us/powershell/azure/troubleshooting
#################################################################################################################################################################################################

#################################################################################################################################################################################################
# This script exports an Azure App Service Certificate in PFX format, being this PFX format required when importing App-Core's wildcard certificates into an Azure Key Vault
# How to run this script
# ./03-export-appServiceCertificate.ps1 -loginId cloud-admin@example.com -subscriptionId yourSubID -subscriptionName yourSubscriptionName -resourceGroupName resourceGroupNameOfYourAppServiceCertificate -appServiceCertificateName appServiceCertificateName"
#
# Example:
# ./03-export-appServiceCertificate.ps1 -loginId cloud-admin@example.com -subscriptionId 00000000-0000-0000-0000-000000000000 -subscriptionName "Enterprise Infrastructure Subscription" -resourceGroupName CertificatesResourceGroup -appServiceCertificateName cert-wildcard-deng-Enterprise-com
#
# Possible locations of Powershell Modules:
#   /Users/<username>/.local/share/powershell/Modules
#   /usr/local/share/powershell/Modules
#   /usr/local/microsoft/powershell/7/Modules
#   etc
#
# Option 1) Make sure you have Az Powershell modules installed (/Users/<username>/.local/share/powershell/Modules):
#   pwsh
#   Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
# Change file permissions if the previous command fails on your macOS due to lack of permissions in your home directory:
#   sudo chown -R <username>: /Users/<username>/.local/share/powershell/Modules
# 
# Option 2) Install Powershell Modules with -Scope AllUsers (/usr/local/share/powershell/Modules):
#   sudo su -
#   Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
#
# Known Error:
#   Write-Error: This module requires Az.Accounts version 2.10.0. An earlier version of Az.Accounts is imported in the current PowerShell session. Please open a new session before importing this module. 
#   This error could indicate that multiple incompatible versions of the Azure PowerShell cmdlets are installed on your system. Please see https://aka.ms/azps-version-error for troubleshooting information.
#   Import-Module: The module to process 'Az.KeyVault.psm1', listed in field 'ModuleToProcess/RootModule' of module manifest '/usr/local/share/powershell/Modules/Az.KeyVault/4.7.0/Az.KeyVault.psd1' was not processed 
#   because no valid module was found in any module directory.
# Solution: https://github.com/Azure/azure-powershell/blob/main/documentation/troubleshoot-module-load.md
#   1. Get-Module -ListAvailable
#   2. Remove one of the duplicated modules
#################################################################################################################################################################################################

#################################################################################################################################################################################################
# Check if the certificate chain is included in your PFX file with MacOS Keychain Access:
#    MacOS Finder app -> right click on certificate.pfx -> Quick Look -> Open with Keychain Access
#################################################################################################################################################################################################

Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="ARM Login Url")]
    [string]$loginId,
    
    [Parameter(Mandatory=$true,HelpMessage="Subscription Id")]
    [string]$subscriptionId,
    
    [Parameter(Mandatory=$true,HelpMessage="Subscription Name")]
    [string]$subscriptionName,
    
    [Parameter(Mandatory=$true,HelpMessage="Resource Group Name")]
    [string]$resourceGroupName,
    
    [Parameter(Mandatory=$true,HelpMessage="Name of the App Service Certificate Resource")]
    [string]$appServiceCertificateName
)
Write-Host "This script will be run with the following parameters:"
Write-Host "loginId: $loginId"           
Write-Host "subscriptionId: $subscriptionId"    
Write-Host "subscriptionName: $subscriptionName"
Write-Host "resourceGroupName: $resourceGroupName"
Write-Host "appServiceCertificateName: $appServiceCertificateName"

Function Export-AppServiceCertificate
{
    ###########################################################
    
    Param(
    [Parameter(Mandatory=$true,Position=1,HelpMessage="ARM Login Url")]
    [string]$loginId,
    
    [Parameter(Mandatory=$true,HelpMessage="Subscription Id")]
    [string]$subscriptionId,
    
    [Parameter(Mandatory=$true,HelpMessage="Subscription Name")]
    [string]$subscriptionName,
    
    [Parameter(Mandatory=$true,HelpMessage="Resource Group Name")]
    [string]$resourceGroupName,
    
    [Parameter(Mandatory=$true,HelpMessage="Name of the App Service Certificate Resource")]
    [string]$name
    )
    
    ###########################################################
    
    az account set --subscription $subscriptionName
    az account show
    
    Connect-AzAccount
    Set-AzContext -Subscription $subscriptionId
    
    ## Get the KeyVault Resource Url and KeyVault Secret Name were the certificate is stored
    $ascResource= Get-AzResource -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.CertificateRegistration/certificateOrders/$name"
    $certProps = Get-Member -InputObject $ascResource.Properties.certificates[0] -MemberType NoteProperty
    $certificateName = $certProps[0].Name
    $keyVaultId = $ascResource.Properties.certificates[0].$certificateName.KeyVaultId
    $keyVaultSecretName = $ascResource.Properties.certificates[0].$certificateName.KeyVaultSecretName
    
    ## Split the resource URL of KeyVault and get KeyVaultName and KeyVaultResourceGroupName
    $keyVaultIdParts = $keyVaultId.Split("/")
    $keyVaultName = $keyVaultIdParts[$keyVaultIdParts.Length - 1]
    $keyVaultResourceGroupName = $keyVaultIdParts[$keyVaultIdParts.Length - 5]
    
    ## --- !! NOTE !! ----
    ## Only users who can set the access policy and has the the right RBAC permissions can set the access policy on KeyVault, if the command fails contact the owner of the KeyVault
    Set-AzKeyVaultAccessPolicy -ResourceGroupName $keyVaultResourceGroupName -VaultName $keyVaultName -UserPrincipalName $loginId -PermissionsToSecrets get
    Write-Host "Get Secret Access to account $loginId has been granted from the KeyVault, please check and remove the policy after exporting the certificate"    
    
    ## Getting the secret from the KeyVault
    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName
    #write-host "secret is:"
    #Write-Host ($secret | Format-List | Out-String)
    
    $secretValueText = '';
    $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
    try {
        $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
    }
    #write-host "secretValueText is:"
    #$secretValueText
    $secretByte = [Convert]::FromBase64String($secretValueText)    
    
    ##########################################################################################################################################
    # GOAL: include all the certificates in the certification path
    # Check: Azure App Gateway V2: the importance of the certificate chain:
    # http://blog.repsaj.nl/index.php/2019/08/azure-application-gateway-certificate-gotchas/
    ##########################################################################################################################################
    
    ##########################################################################################################################################
    # Certificate chain is NOT included:
    # https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509certificate2
    # https://www.ssllabs.com/ssltest : This server's certificate chain is incomplete. Grade capped to B.
    ##########################################################################################################################################
    $pfxCertObject = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($secretByte, "", "Exportable,PersistKeySet")
    
    ##########################################################################################################################################    
    # Workaround to the certificate chain issue: Apparently we cannot export the certificate chain via scripting, this needs to be accomplished
    # via a manual approach, see:
    # https://azure.github.io/AppService/2000/01/01/Creating-a-local-PFX-copy-of-App-Service-Certificate.html
    # Exporting the certificate with the chain included for App Service Web App consumption.
    # The pfx created by the above commands will not include certificates from the chain. Services like Azure App Services expect the 
    # certificates that are being uploaded to have all the certificates in the chain included as part of the pfx file. 
    # To get the certificates of the chain to be part of the pfx, you will need to install the exported certificate on your machine first 
    # using the password that is provided by the script, make sure you mark the certificate as exportable.
    ##########################################################################################################################################
    
    ##########################################################################################################################################
    # PFX export
    ##########################################################################################################################################    
    $type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
    #write-host "show pfxcertobject:"
    #$pfxCertObject
    $pfxPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 50 | % {[char]$_})
    #$pfxPassword = 'EnterpriseEasy31'
    $export = $pfxCertObject.Export($type, $pfxPassword)
    $currentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
    $destination = "$currentDirectory/appservicecertificate.pfx"
    [io.file]::WriteAllBytes($destination, $export)
    
    ## --- !! NOTE !! ----
    ## Remove the Access Policy required for exporting the certificate once you have exported the certificate to prevent giving the account prolonged access to the KeyVault
    ## The account will be completely removed from KeyVault access policy and will prevent to account from accessing any keys/secrets/certificates on the KeyVault, 
    ## Run the following command if you are sure that the account is not used for any other access on the KeyVault or login to the portal and change the access policy accordingly.
    # Remove-AzKeyVaultAccessPolicy -ResourceGroupName $keyVaultResourceGroupName -VaultName $keyVaultName -UserPrincipalName $loginId
    # Write-Host "Access to account $loginId has been removed from the KeyVault"
    
    # Print the password for the exported certificate
    Write-Host "Created an App Service Certificate copy at: $currentDirectory/appservicecertificate.pfx"
    Write-Warning "For security reasons, do not store the PFX password. Use it directly from the console as required."
    Write-Host "PFX password: $pfxPassword"
}

$DebugPreference = 'Continue' # Enable debug logging in Az powershell (you will see all the MSAL/OAuth2.0 Workflow within your az cmdlets)
Export-AppServiceCertificate -loginId $loginId -subscriptionId $subscriptionId -subscriptionName $subscriptionName -resourceGroupName $resourceGroupName -name $appServiceCertificateName
""
""
Write-Host "######################################################################################################################"
Write-Host "Certificate chain needs to be included manually to the PFX file!!"
Write-Host ""
Write-Host "Go to to https://certs.godaddy.com/repository and on 'GoDaddy Certificate Chain - G2'" 
Write-Host "download the INTERMEDIATE certificates and the ROOT certificate (or a CA Bundle)"
Write-Host ""
Write-Host "A CA bundle is a file that contains root and intermediate certificates. The end-entity certificate"
write-Host "along with a CA bundle constitutes the certificate chain."
Write-Host ""
Write-Host "OPTION 1) How to add intermediate certificates with Windows OS - the easy way:"
Write-Host "Check https://azure.github.io/AppService/2000/01/01/Creating-a-local-PFX-copy-of-App-Service-Certificate.html"
Write-Host "Install all of the certificates downloaded to the same store as your certificate. Once you confirmed that all the" 
Write-Host "certificates in the chain have been installed we can export the certificate with the chain"
Write-Host ""
Write-Host "OPTION 2) How to add intermediate certificates with openssl - the hard way:"
Write-Host "2.1) Add passphrase to a file (required by macOS 13.0.1 Ventura, Nov 2022):"
Write-Host "vim passphrasefile.txt"
Write-Host "2.2) Convert the PFX to PEM:"
Write-Host "openssl pkcs12 -in appservicecertificate.pfx -out appservicecertificate.pem -nodes -passin file:passphrasefile.txt"
Write-Host "2.3) See the placement of the Certs in the Bundle"
Write-Host "cat appservicecertificate.pem"
Write-Host "2.4) Convert correct Root certificates from DER form to PEM (.crt & .cert are synonyms)"
Write-Host "openssl x509 -inform der -in root_cert.cer -out root_cert.pem"
Write-Host "openssl x509 -inform der -in intermediate_cert1.crt -out intermediate_cert1.pem"
Write-Host "openssl x509 -inform der -in intermediate_cert2.cer -out intermediate_cert2.pem"
Write-Host "openssl x509 -inform der -in intermediate_certX.crt -out intermediate_certX.pem"
Write-Host ""
Write-Host "Examples of Root + intermediate certificates + CA bundles at GoDaddy:"
Write-Host "    gdroot-g2.crt"
Write-Host "    gdig2.crt"
Write-Host "    mscvr-cross-gdroot-g2.crt"
Write-Host "    gdicsg2.cer"
Write-Host "    gd_evcs-g2.crt"
Write-Host "    gd_bundle-g2.crt"
Write-Host "    gdig2_bundle.crt"
Write-Host "    gd_bundle-g2-g1.crt"
Write-Host ""
Write-Host "2.5) Text editor to add 2 correct Roots in and REMOVE INCORRECT Root"
Write-Host "vim appservicecertificate.pem"
Write-Host "2.6) Repeate with intermediate certificates"
Write-Host "2.7) Command to convert the PEM bundle to PFX (outcome: new.pfx):"
Write-Host "openssl pkcs12 -export -out new.pfx -in appservicecertificate.pem"
Write-Host ""
Write-Host ""
Write-Host "Once the above manual steps have been accomplished the pfx file is complete and ready to be used"
Write-Host "######################################################################################################################"
""



