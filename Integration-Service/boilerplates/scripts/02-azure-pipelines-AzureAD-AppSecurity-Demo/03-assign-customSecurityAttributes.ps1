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
$spName=$args[0]
write-host $spName
$centerName=$args[1]
write-host $centerName   # AETitle

#################
# Start of script
#################

## Enable debug logging
$DebugPreference = 'Continue'

Write-Host "Get access token of Microsoft Graph endpoint for current account:"
$accessToken = Get-AzAccessToken -ResourceTypeName MSGraph # Get access token of Microsoft Graph endpoint for current account
#$accessToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/"  # A working alternative 
# Ouput of Get-AzAccessToken is an PSAccessToken object. check https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.commands.profile.models.psaccesstoken
""
""
""
#####################################################################
# Connect-MgGraph 
# The SDK supports two types of authentication: delegated access and app-only access.
# App-only access via Client Credential with a certificate.
# 
# https://github.com/microsoftgraph/msgraph-sdk-powershell
#####################################################################
Write-Host "Connect-MgGraph -AccessToken"
Connect-MgGraph -AccessToken $accessToken.Token

#######################################################################################################################################################################
# Connect-MgGraphAz (Microsoft Graph Extension): An alternative to "Connect-MgGraph -AccessToken" (finally not necessary):
#
# [FEATURE REQUEST] Add Connect-Graph -AzContext Option : https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/509
# https://www.powershellgallery.com/packages/JustinGrote.Microsoft.Graph.Extensions/
# https://github.com/JustinGrote/JustinGrote.Microsoft.Graph.Extensions/blob/main/src/Public/Connect-MgGraphAz.ps1
# Write-Host "Install Graph Extension: JustinGrote.Microsoft.Graph.Extensions" #https://www.powershellgallery.com/packages/JustinGrote.Microsoft.Graph.Extensions/
# Install-Module -Name JustinGrote.Microsoft.Graph.Extensions -Force -AllowClobber

# Write-Host "Get-Command -Module JustinGrote.Microsoft.Graph.Extensions"
# Get-Command -Module JustinGrote.Microsoft.Graph.Extensions 

# # CommandType     Name                                               Version    Source                                   
# # -----------     ----                                               -------    ------                                   
# # Function        Connect-MgGraphAz                                  0.0.2      JustinGrote.Microsoft.Graph.Extensions   
# # Function        Disable-MgEventualConsistencyDefault               0.0.2      JustinGrote.Microsoft.Graph.Extensions   
# # Function        Get-MgAppRole                                      0.0.2      JustinGrote.Microsoft.Graph.Extensions   
# # Function        Get-MgManagedIdentity                              0.0.2      JustinGrote.Microsoft.Graph.Extensions   
# # Function        Get-MgO365ServicePrincipal                         0.0.2      JustinGrote.Microsoft.Graph.Extensions 

# Write-Host "Connect-MgGraphAz"
# Get-AzContext | Connect-MgGraphAz
#######################################################################################################################################################################


# By default, the SDK uses the Microsoft Graph REST API v1.0. You can change this by using the Select-MgProfile command.
Write-Host "Select MgProfile Beta"
Write-Host "Without MgProfile Beta new cmdlets like New-MgDirectoryAttributeSet are NOT recognized"
Select-MgProfile -Name "beta"
""
""
""
Write-Host "Get-MgContext"
#View my scope
Get-MgContext
""
""
""
Write-Host "View My Scopes: (Get-MgContext).Scopes"
(Get-MgContext).Scopes
""
""
""
Write-Host "Powershell: Assign a custom security attribute with a string value to a service principal"
# https://docs.microsoft.com/en-us/graph/api/serviceprincipal-update?view=graph-rest-beta&tabs=powershell
#   To assign custom security attributes, the calling principal must be assigned the 
#   Attribute Assignment Administrator role and must be granted the CustomSecAttributeAssignment.ReadWrite.All permission.

# Howto call a REST API:
# https://github.com/johnthebrit/RandomStuff/blob/master/FunctionResGraphPowerShell/CallRestAPI.ps1


Write-Host "get Service Principal Object ID:"
$spObj = Get-MgServicePrincipal -Filter "DisplayName eq '$spName'" 
$spObj
""
""
""
#Simple Test Harness to call a rest API
$URIValue = "https://graph.microsoft.com/beta/servicePrincipals/$($spObj.Id)"

# Write-Host "Get Access Token:"
# $accessToken= az account get-access-token --resource-type ms-graph | ConvertFrom-Json
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $accessToken.Token
}
Write-Host "Invoke-RestMethod GET"
$resp = Invoke-RestMethod -Uri $URIValue -Method GET -Headers $authHeader
$resp

# $BodyJSON = '{
# 	"customSecurityAttributes": {
#         "EnterpriseCore": {
#             "@odata.type": "#Microsoft.DirectoryServices.CustomSecurityAttributeValue",
#             "AETitle": "enterprise"
#         }
#     }
# }'

# Pretty json in powershell with arrays and ConverTo-Json:
$BodyJSON = @{
    "customSecurityAttributes" = @{
            "EnterpriseCore" = @{
              "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
              "AETitle" = "$centerName"
            }
        }
} | ConvertTo-Json

write-host "URIValue:"
$URIValue
""
""
""
Write-Host "authHeader"
$authHeader 
""
""
""
Write-Host "BodyJSON:"
$BodyJSON
""
""
""
Write-Host "Invoke-RestMethod PATCH"
$response = Invoke-RestMethod -Uri $URIValue -Method 'Patch' -Headers $authHeader -Body $BodyJSON -ContentType 'application/json'
    # or use Invoke-WebRequest (RestMethod automatically parses returned JSON in content but less overall info)
$content = $response.Status
Write-Host "content:"
$content
""
""
""
"Waiting for the assignment to be fully provisioned..."
Start-Sleep -Seconds 30
