# Do not do this since it should be done manually:
# peteskelly.com: Grant Admin Consent to Azure AD Apps in Azure Pipelines: https://peteskelly.com/grant-admin-consent-from-azure-pipelines/
#
# In consequence, we need to grant admin consent manually before running THIS script. 

# https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/custom-security-attributes-add#add-an-attribute-set
# https://docs.microsoft.com/en-us/graph/custom-security-attributes-examples


# Microsoft Graph Access Token Acquisition with PowerShell explained in depth
# https://tech.nicolonsky.ch/explaining-microsoft-graph-access-token-acquisition/

##################################################################################################
# Connecting to Microsoft GraphAPI Using PowerShell
# https://thesleepyadmins.com/2000/01/01/connecting-to-microsoft-graphapi-using-powershell/
# $ApplicationID = ""
# $TenatDomainName = ""
# $AccessSecret = Read-Host "Enter Secret"
#
# $Body = @{    
# Grant_Type    = "client_credentials"
# Scope         = "https://graph.microsoft.com/.default"
# client_Id     = $ApplicationID
# Client_Secret = $AccessSecret
# } 
#
# $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenatDomainName/oauth2/v2.0/token" `
# -Method POST -Body $Body
# $token = $ConnectGraph.access_token
##################################################################################################


# https://docs.microsoft.com/en-us/powershell/microsoftgraph/find-mg-graph-command?view=graph-powershell-beta
# PS> Find-MgGraphCommand -Command 'Update-MgServicePrincipal'
#
#    APIVersion: v1.0
# Command                   Module       Method URI                                      OutputType Permissions                                             Variants
# -------                   ------       ------ ---                                      ---------- -----------                                             --------
# Update-MgServicePrincipal Applications PATCH  /servicePrincipals/{servicePrincipal-id}            {Application.ReadWrite.All, Directory.AccessAsUser.All} {Update1, UpdateExpanded1, UpdateViaIdentity1, UpdateViaIdentityExpanded1}
#    APIVersion: beta
# Command                   Module       Method URI                                      OutputType Permissions                                             Variants
# -------                   ------       ------ ---                                      ---------- -----------                                             --------
# Update-MgServicePrincipal Applications PATCH  /servicePrincipals/{servicePrincipal-id}            {Application.ReadWrite.All, Directory.AccessAsUser.All} {Update, UpdateExpanded, UpdateViaIdentity, UpdateViaIdentityExpanded}


# https://docs.microsoft.com/en-us/powershell/microsoftgraph/find-mg-graph-permission?view=graph-powershell-beta
# How do I find the values to supply to the permission-related parameters of commands like New-MgApplication and other application and consent related commands?
# What permissions are applicable to a certain domain, for example, application, directory? To use Microsoft Graph PowerShell SDK to access Microsoft Graph, 
# users must sign in to an Azure Active Directory application using the Connect-MgGraph command. Use the Find-MgGraphCommand to find which permissions to use for a specific cmdlet or API.
#
# PS> Find-MgGraphPermission application       
#
# PermissionType: Delegated
#
# Id                                   Consent Name                                      Description
# --                                   ------- ----                                      -----------
# 00000000-0000-0000-0000-000000000000 Admin   Application.Read.All                      Allows the app to read applications and service principals on behalf of the signed-in user.
# 00000000-0000-0000-0000-000000000000 Admin   Application.ReadWrite.All                 Allows the app to create, read, update and delete applications and service principals on behalf of the signed-in user. Does not allow management of consent grants.
# 00000000-0000-0000-0000-000000000000 Admin   Policy.ReadWrite.ApplicationConfiguration Allows the app to read and write your organization's application configuration policies on behalf of the signed-in user.  This includes policies such as activityBasedTimeoutPolicy, claimsMappingPolicy, homeRealmDiscoveryPolicy,  tokenIssuancePolicy and tokenLifetimePolicy.
#
# PermissionType: Application
#
# Id                                   Consent Name                                      Description
# --                                   ------- ----                                      -----------
# 00000000-0000-0000-0000-000000000000 Admin   Application.Read.All                      Allows the app to read all applications and service principals without a signed-in user.
# 00000000-0000-0000-0000-000000000000 Admin   Application.ReadWrite.All                 Allows the app to create, read, update and delete applications and service principals without a signed-in user.  Does not allow management of consent grants.
# 00000000-0000-0000-0000-000000000000 Admin   Application.ReadWrite.OwnedBy             Allows the app to create other applications, and fully manage those applications (read, update, update application secrets and delete), without a signed-in user.  It cannot update any apps that it is not an owner of.
# 00000000-0000-0000-0000-000000000000 Admin   Policy.ReadWrite.ApplicationConfiguration Allows the app to read and write your organization's application configuration policies, without a signed-in user.  This includes policies such as activityBasedTimeoutPolicy, claimsMappingPolicy, homeRealmDiscoveryPolicy, tokenIssuancePolicy  and tokenLifetimePolicy.


Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName
$devopsAzurePipelineSpName=$args[1]
write-host $devopsAzurePipelineSpName

#################
# Start of script
#################

Write-Host "Grab existing registered app and its service principal"
$existingRegisteredAppId = az ad app list --display-name $appName --query "[0].appId" -o tsv
$existingRegisteredAppId

Write-Host "Grab service principal ID assgined to the DevOps Azure Pipeline that runs this script"
$devopsAzurePipelineSpId = az ad app list --display-name $devopsAzurePipelineSpName --query "[0].appId" -o tsv
$devopsAzurePipelineSpId


Write-Host "az ad app permission list-grants --id: "
$permissionListGrants = az ad app permission list-grants --id $existingRegisteredAppId
$permissionListGrants

Write-Host "Create a self-signed certificate"
# Create a self-signed certificate in the local machine personal certificate store (Provide proper subjectname and notedown thumbprint)
New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -Subject CN=CertLogin -KeySpec KeyExchange -FriendlyName CertLogin
#Store the thumbprint information which can I use later for authentication
$Certificate = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -eq 'CN=CertLogin'}

# Display the new certificate properties
$Certificate | Format-List -Property *

# Display thumbprint
$thumbprint =  $Certificate.Thumbprint

$cert = Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint
$certFileCERT = 'appReg.cer'
Export-Certificate -Cert $cert -FilePath $certFileCERT -Type CERT
$certFilePEM = 'appReg.pem'
certutil -encode $certFileCERT $certFilePEM

Write-Host "Content of self signed PEM file:"
Get-Content -Path $certFilePEM 

##############################
# Adding certificate to SP
##############################
# ad ad sp credential: This command group now operates on service principal, not application
Write-Host "az ad app credential reset"
az ad app credential reset --id $devopsAzurePipelineSpId --cert "@./$certFilePEM" --append 

# wait for the AAD app to be created or the script will fail later on
"Waiting for the app to be fully provisioned..."
Start-Sleep -Seconds 45



Write-Host "Get Access Token:"
$accessToken= az account get-access-token --resource-type ms-graph | ConvertFrom-Json
Write-Host "Access token is: $accessToken.accessToken"
$myAccessToken=$accessToken.accessToken

Write-Host "setup gobal variable needed by the next task:"
Write-Host "##vso[task.setvariable variable=devopsAzurePipelineSpId]$devopsAzurePipelineSpId"


Write-Host "setup gobal variable needed by the next task:"
Write-Host "##vso[task.setvariable variable=thumbprint]$thumbprint"


Write-Host "setup gobal variable needed by the next task:"
Write-Host "##vso[task.setvariable variable=myAccessToken]$myAccessToken"