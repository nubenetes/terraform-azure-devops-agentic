################################################################################################º
# Code snippets - this is NOT a script but a collections of code snippets and references 
################################################################################################º


#View my scope
Write-Host "View my scope:"
Get-MgContext
(Get-MgContext).Scopes

Write-Host "View my environments:"
#Environments, i.e. various clouds
Get-MgEnvironment

Write-Host "Get tenant info"
#Get tenant info
Get-MgOrganization | Select-Object DisplayName, City, State, VerifiedDomains
Get-MgOrganization | Select-Object -expand AssignedPlans


# Assign Attribute Assignment Administrator role to our SP
#az role assignment create --assignee-object-id $spObj.Id \
#--assignee-principal-type "ServicePrincipal" \
#--role "Attribute Assignment Administrator" \
#--resource-group "{resourceGroupName}" \
#--scope "/subscriptions/{subscriptionId}"


Write-Host "Update-MgServicePrincipal with custom security attributes:"

# 1st attempt:
# $spParams = @{
# 	EnterpriseCore = @{
# 	   "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
# 	   AETitle = "enterprise"
# 	}
# }
# Update-MgServicePrincipal -ServicePrincipalId $spObj.Id -CustomSecurityAttributes $spParams
# Update-MgServicePrincipal : AttributeSet for value you are trying to assign does not exist EnterpriseCore

# 2nd attempt:
# $spParams = @{
# 	CustomSecurityAttributes = @{
# 		EnterpriseCore = @{
#  		   "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
# 		   AETitle = "enterprise"
# 		}
# 	}
# }
# Update-MgServicePrincipal -ServicePrincipalId $spObj.Id -BodyParameter $spParams
# Error: Update-MgServicePrincipal : AttributeSet for value you are trying to assign does not exist EnterpriseCore




# 3rd attempt:
###################################################################################################################
# Code based on Azure AD PowerShell (which should be migrated to Microsoft Graph Powershell)
#
# https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/custom-security-attributes-apps

# $attributes = @{
#     Engineering = @{
#         "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
#         "Project@odata.type" = "#Collection(String)"
#         Project = @("Baker","Cascade")
#     }
# }
# Set-AzureADMSServicePrincipal -Id 00000000-0000-0000-0000-000000000000 -CustomSecurityAttributes $attributes
####################################################################################################################
# $attributes = @{
#     Engineering = @{
#         "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
# 		AETitle = "enterprise"
#     }
# }
#Set-AzureADMSServicePrincipal -Id $spObj.Id -CustomSecurityAttributes $attributes
#Set-AzureADMSServicePrincipal -Id '00000000-0000-0000-0000-000000000000' -CustomSecurityAttributes $attributes
# ObjectNotFound: (Set-AzureADMSServicePrincipal:String)





# 4th attempt:
# https://github.com/johnthebrit/RandomStuff/blob/master/AzureAD/MGAADDemo.ps1
# Look at custom attributes
# Connect-MgGraph -Scopes "User.Read.All","CustomSecAttributeAssignment.ReadWrite.All"
# Get-MgDirectoryAttributeSet
# $user = Get-MgUser -UserId clark@savilltech.net
# $user | Format-List
# $user.CustomSecurityAttributes

# $accessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token #MS Graph audience
# $authHeader = @{
#     'Content-Type'='application/json'
#     'Authorization'='Bearer ' + $accessToken
# }
# $resp = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/users/$($user.Id)" -Method GET -Headers $authHeader
# $resp




#Look at custom attributes
#Connect-MgGraph -Scopes 'Application.Read.All','CustomSecAttributeAssignment.ReadWrite.All'



# https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.applications/get-mgserviceprincipal?view=graph-powershell-beta
# Connect-MgGraph -Scopes 'Application.Read.All'
# Get-MgServicePrincipal -Filter "DisplayName eq 'sp-integration-service-enterprise-dev'" | 
#   Format-List Id, DisplayName,AppId, SignInAudience



# $spAttributes = Get-MgServicePrincipal -Filter "DisplayName eq 'sp-integration-service-enterprise-dev'" 
# $spAttributes | Format-List 


# $spAttributes.CustomSecurityAttributes

# $user = Get-MgUser -UserId clark@savilltech.net
# $user | Format-List
# $user.CustomSecurityAttributes


# Connect-MgGraph -Scopes "User.Read.All","CustomSecAttributeAssignment.ReadWrite.All"
# Get-MgDirectoryAttributeSet











# PS > Connect-MgGraph -Scopes "CustomSecAttributeAssignment.ReadWrite.All","CustomSecAttributeDefinition.ReadWrite.All"
# Welcome To Microsoft Graph!
# PS > Get-MgDirectoryAttributeSet                                                                                      

# Id              Description                              MaxAttributesPerSet
# --              -----------                              -------------------
# EnterpriseCore      Attributes for managing core Multitenant 25
# EnterpriseCoreTwo   Attributes for EnterpriseCore team           25
# EnterpriseCoreThree test                                     25
# EnterpriseCoreFour  Attributes for other team                25


# PS > Get-MgDirectoryCustomSecurityAttributeDefinition
# Id                                    AttributeSet   Description                   IsCollection IsSearchable Name                       Status     Type    UsePreDefinedValuesOnly
# --                                    ------------   -----------                   ------------ ------------ ----                       ------     ----    -----------------------
# EnterpriseCore_AETitle                    EnterpriseCore     Center                        False        True         AETitle                    Available  String  False
# EnterpriseCore_AcceptedTerms              EnterpriseCore     Terms & Conditions            True         True         AcceptedTerms              Deprecated String  True
# EnterpriseCore_AcceptedTermsAndConditions EnterpriseCore     Accepted Terms And Conditions False        True         AcceptedTermsAndConditions Available  Boolean False
# EnterpriseCoreFour_ProjectDate            EnterpriseCoreFour project date                  False        True         ProjectDate                Available  String  False


# https://learningbydoing.cloud/blog/control-access-to-azure-storage-blobs-with-abac/
# https://docs.microsoft.com/en-us/graph/custom-security-attributes-examples
# Custom security attributes can be assigned or updated only through a PATCH operation in an Update user or Update servicePrincipal request.
# https://docs.microsoft.com/en-us/graph/api/serviceprincipal-update?view=graph-rest-beta&preserve-view=true&tabs=http




Write-Host "Install-Module MSAL"
# https://tech.nicolonsky.ch/explaining-microsoft-graph-access-token-acquisition/
#Install-Module -Name MSAL.PS -Scope CurrentUser
Install-Module MSAL.PS -SkipPublisherCheck -Force

Write-Host "Get Access Token with Get-MsalToken"
$connectionDetails = @{
    'TenantId'          = '00000000-0000-0000-0000-000000000000'
    'ClientId'          = $existingRegisteredAppId
    'ClientCertificate' = $cert
}

# Building a request header
# To actually use the acquired access token we need to build a request header that we include in http requests to the Graph API. 
# A PowerShell object instantiated from the Get-MsalToken commandlet exposes a method called CreateAuthorizationHeader() to include the 
# Bearer token in the request header you use for subsequent requests:

$token = Get-MsalToken @connectionDetails

$authHeader = @{
    'Authorization' = $token.CreateAuthorizationHeader()
}

$requestUrl = "https://graph.microsoft.com/v1.0/me"
Invoke-RestMethod -Uri $requestUrl -Headers $authHeader

#Token cache
# In memory tokens can be cleared with:
Clear-MsalTokenCache










#API from REST. Already signed into Az so use to get a graph token
$accessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token #MS Graph audience
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $accessToken
}






$spName = 'appr-integration-service-OnPrem-test'
$spObj = Get-MgServicePrincipal -Filter "DisplayName eq '$spName'" 
$spObj

$params = @{
	CustomSecurityAttributes = @{
		EnterpriseCore = @{
 		   "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
		   AETitle = "enterprise"
		}
	}
}
Update-MgServicePrincipal -ServicePrincipalId $spObj.Id -BodyParameter $params
# Update-MgServicePrincipal_Update: AttributeSet for value you are trying to assign does not exist EnterpriseCore







# Connect-MgGraph -Scopes "CustomSecAttributeAssignment.ReadWrite.All","CustomSecAttributeDefinition.ReadWrite.All","Application.ReadWrite.All"
#Submit the REST call for the list guest users!
### NOTE IN POWERSHELL I HAVE TO ESCAPE THE $ or it gets ignored!!!!
$resp = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/servicePrincipals/00000000-0000-0000-0000-000000000000" -Method PATCH -Headers $spParams
$resp.value











Connect-AzAccount

#API from REST. Already signed into Az so use to get a graph token
$accessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token #MS Graph audience
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $accessToken
}
#Submit the REST call for the list guest users!
### NOTE IN POWERSHELL I HAVE TO ESCAPE THE $ or it gets ignored!!!!
$resp = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/?`$filter=userType eq 'guest'" -Method GET -Headers $authHeader
$resp.value



Connect-MgGraph -Scopes "Applications.Read.All","CustomSecAttributeAssignment.ReadWrite.All"





https://graph.microsoft.com/beta/servicePrincipals/00000000-0000-0000-0000-000000000000

{
    "customSecurityAttributes": {
        "EnterpriseCore": {
            "@odata.type": "#Microsoft.DirectoryServices.CustomSecurityAttributeValue",
            "AETitle": "enterprise"
        }
    }
}






https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/users-custom-security-attributes

GET https://graph.microsoft.com/beta/users/{id}?$select=customSecurityAttributes


# https://docs.microsoft.com/en-us/graph/custom-security-attributes-examples






PS >  Set-AzContext 00000000-0000-0000-0000-000000000000   # Subscription ID

Name                                     Account                                                      SubscriptionName                                             Environment                                                  TenantId
----                                     -------                                                      ----------------                                             -----------                                                  --------
enterprise CloudOps Dev Subscription (fac3c… cloud-admin@example.com                                    enterprise CloudOps Dev Subscription                             AzureCloud                                                   00000000-0000-0000-0000-000000000000


PS > Get-AzContext                                                                                

Name                                     Account                                                      SubscriptionName                                             Environment                                                  TenantId
----                                     -------                                                      ----------------                                             -----------                                                  --------
enterprise Infrastructure Subscription (493… cloud-admin@example.com                                    enterprise Infrastructure Subscription                           AzureCloud                                                   00000000-0000-0000-0000-000000000000