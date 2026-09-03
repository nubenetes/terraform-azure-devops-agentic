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



# $appName = "appr-integration-service-OnPrem-test"
# $spName = "appr-integration-service-OnPrem-test"
# $tenant = "00000000-0000-0000-0000-000000000000"

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName
$spName=$args[1]
write-host $spName
$tenant=$args[2]
write-host $tenant
$devopsAzurePipelineSpName=$args[3]
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


if ($permissionListGrants.count -le 1)  # -le less than or equal
{

	Write-Host "==========================================================================================================="
	Write-Host "Admin-Consent permissions NOT granted."
	Write-Host "Make sure your Application have admin-consent permissions before this script is run"
	Write-Host "You must login as a global administrator. "
	Write-Host "We cannot do this via this script run by a pipeline (unattended)"
	Write-Host ""
	Write-Host ""
	Write-Host "Please run manually the following AZ CLI as an Azure Global Administrator:"
	Write-Host ""
	Write-Host "az ad app permission admin-consent --id $existingRegisteredAppId"
	Write-Host ""
	Write-Host "==========================================================================================================="
	Exit 1
}


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

########################################################
# Adding certificate to SP assigned to registered App
########################################################
# ad ad sp credential: This command group now operates on service principal, not application
Write-Host "az ad app credential reset"
az ad app credential reset --id $existingRegisteredAppId --cert "@./$certFilePEM" --append 

# wait for the AAD app to be created or the script will fail later on
"Waiting for the app to be fully provisioned..."
Start-Sleep -Seconds 45


#####################################################################
# Connect-MgGraph 
# The SDK supports two types of authentication: delegated access and app-only access.
# App-only access via Client Credential with a certificate.
# 
# https://github.com/microsoftgraph/msgraph-sdk-powershell
#####################################################################
Write-Host "Connect-MgGraph to SP with ID $devopsAzurePipelineSpId"
Connect-MgGraph -ClientId $existingRegisteredAppId -TenantId $tenant -CertificateThumbprint $thumbprint

# By default, the SDK uses the Microsoft Graph REST API v1.0. You can change this by using the Select-MgProfile command.
Write-Host "Select MgProfile Beta"
Write-Host "Without MgProfile Beta new cmdlets like New-MgDirectoryAttributeSet are NOT recognized"
Select-MgProfile -Name "beta"


Write-Host "View My Scopes:"
#View my scope
Get-MgContext
(Get-MgContext).Scopes


