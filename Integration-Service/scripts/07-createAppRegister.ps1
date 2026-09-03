# https://www.agrenpoint.com/azcli-adscope/
# https://medium.com/medialesson/create-azure-active-directory-app-registration-with-azure-cli-3241aa3824c5

# https://github.com/microsoftgraph/msgraph-sdk-powershell
# https://github.com/microsoftgraph/msgraph-sdk-powershell/blob/dev/samples/9-Applications.ps1

# Microsoft Graph or Azure AD Graph
# https://docs.microsoft.com/en-us/archive/blogs/aadgraphteam/microsoft-graph-or-azure-ad-graph

# Microsoft Graph Security API overview
# https://docs.microsoft.com/en-us/graph/security-concept-overview
# https://github.com/microsoftgraph/security-api-solutions/tree/master/Samples/PowerShell
# https://developer.microsoft.com/en-us/graph/gallery/?filterBy=Samples,SDKs 

# What Role or Scopes Does An Azure Service Principal Need to Create Applications
# https://stackoverflow.com/questions/71079517/what-role-or-scopes-does-an-azure-service-principal-need-to-create-applications
#      You need to add the scope of this service principal and also change the Azure role of this Service Principal to 'User Access Administrator' 
#      to enable you to modify resources in Azure AD. Also, 'User Access Administrator' role will give the service principal the required permissions 
#      for that Azure role to assign RBAC permissions. Please refer the below command for more details: 
#      az ad sp create-for-rbac --name foo --role User Access Administrator --scopes /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup1}
#
#      You need to give your service principal "App admin" permissions. This allows you to create application registrations and also set their credentials. 
#      And it does not give it rights to do anything else such as manage users and groups. If your intent is to include those, 
#      you need to add additional roles to the service principal.
#      https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#application-administrator

# Azure Active Directory Graph VS Microsoft Graph
# Azure Active Directory Graph: Deprecated
# Microsoft Graph: New API -> use this!
#  
#  AZ CLI with Microsoft Graph:
#     - New "az graph": Azure Resource Graph (Microsoft Graph) 
#     - Migration of old "az ad" commands
#       az ad: Manage Azure Active Directory Graph entities needed for Role Based Access Control.
#       Thoughts: Will "az ad" based commands be replaced by "az graph" commands in the near future? apparently they will be kept while becoming "Microsoft Graph" compliant 
#       AND/OR being replaced by "Microsoft Graph PowerShell Cmdlets" ( https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.applications/ )
#      
#  Azure CLI (latest): https://docs.microsoft.com/en-us/cli/azure/ad?view=azure-cli-latest
#  Overview of Microsoft Graph: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-beta
#  Microsoft Graph migration: https://docs.microsoft.com/en-us/cli/azure/microsoft-graph-migration?tabs=powershell
#
#  WARNING: The underlying Active Directory Graph API will be replaced by Microsoft Graph API in Azure CLI 2.37.0. Please core_FULLY_PLACEHOLDER review all breaking 
#           changes introduced during this migration: https://docs.microsoft.com/cli/azure/microsoft-graph-migration
#
#  Migrate Azure AD Graph apps to Microsoft Graph: 
#        https://docs.microsoft.com/en-us/graph/migrate-azure-ad-graph-overview
#        Azure Active Directory (Azure AD) Graph is deprecated but won't be retired on January 1, 2000 as previously announced. 
#        Listening closely to your feedback about the challenges of migrating such a critical dependency, we're delaying the 
#        retirement date through at least the end of this year, 2022. We’ll provide a retirement update mid-calendar year including 
#        releasing more tools to help you to migrate your apps.
#  Property differences between Azure AD Graph and Microsoft Graph: https://docs.microsoft.com/en-us/graph/migrate-azure-ad-graph-property-differences
#  Azure CLI (latest): 
#       https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest
#       https://docs.microsoft.com/en-us/cli/azure/graph?view=azure-cli-latest
#		Example: serviceprincipal-update 1.0:  https://docs.microsoft.com/en-us/graph/api/serviceprincipal-update?view=graph-rest-1.0&tabs=powershell
#		Example: serviceprincipal-update Beta: https://docs.microsoft.com/en-us/graph/api/serviceprincipal-update?view=graph-rest-beta&tabs=powershell

# List of Microsoft Graph PowerShell Cmdlets
# https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.applications/


Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName
$rgLocation=$args[1] 
write-host $rgLocation
$resourceGroup=$args[2] 
write-host $resourceGroup
$storageAccountTags=$args[3] 
write-host $storageAccountTags
$storageAccount=$args[4]
write-host $storageAccount
$upnName=$args[5]
Write-Host $upnName
$centerName=$args[6]
write-host $centerName

#################
# Start of script
#################
""
""
""
Write-Host "app register timestamp:"
$appRegisterTimestamp = Get-Date -Format "yyyy-MM-dd-HH\h-mm\m-ss\s-ms\m\s"  # Miliseconds: 2022-05-18-12h-59m-46s-5946ms
#$appRegisterTimestamp = Get-Date -Format "yyyyMMdd_HH\hmm\mss\sms\m\s"  # Miliseconds: 20220613_14h08m46s846ms
$appRegisterTimestamp

Write-Host "Generated and unique appName based on app register timestamp:"
$appName = $appName+'-'+$appRegisterTimestamp

Write-Host "SP Name of the registered app is:"
$spName = $appName
$spName

####################################################################################################################
# OPTION 1 (broken due to API changes):
# Adding a Microsoft Graph "User-Read" of type "Delegated permission" (on behalf of the client app) to our registered client app: 
# Write-Host "az ad sp list:"
# $graphId = az ad sp list --query "[?appDisplayName=='Microsoft Graph'].appId | [0]" --all   # '00000000-0000-0000-0000-000000000000'

# Write-Host "graphId var:"
# $graphId

# Write-Host "az ad sp show:"
# $userRead = az ad sp show --id $graphId --query "oauth2Permissions[?value=='User.Read'].id | [0]"   # '00000000-0000-0000-0000-000000000000'

# Write-Host "userRead var:"
# $userRead

# $resources = @"
# [{ "resourceAppId": $graphId, "resourceAccess": [{"id": $userRead,"type": "Scope"}]}]
# "@ | ConvertTo-Json
####################################################################################################################


####################################################################################################################
# OPTION 2:
$graphId = '00000000-0000-0000-0000-000000000000'      # Microsoft Graph ID
Write-Host "graphId var:"
$graphId

$userRead = '00000000-0000-0000-0000-000000000000'   # User.Read - Microsoft Graph Delegated API Permissions 
Write-Host "userRead var:"
$userRead

$resources = @"
[{ "resourceAppId": "$graphId", "resourceAccess": [{"id": "$userRead","type": "Scope"}]}]
"@ | ConvertTo-Json
####################################################################################################################


Write-Host "resources var in JSON format:"
$resources

"Creating AAD app $appName..."
Write-Host "az ad app create"
$app = az ad app create --display-name $appName --required-resource-accesses $resources 
# Remove --password and --credential-description. Use az ad app credential reset to let Graph service create a password for you

#--end-date
#Date or datetime after which credentials expire(e.g. '2017-12-31T11:59:59+00:00' or '2017-12-31'). Default value is one year after current time (means the secret expires in 1 year by default)

#az ad sp create-for-rbac -n "MyApp" --role Contributor --scopes /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup1} /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup2}

Write-Host "Waiting for the app to be provisioned..." 
Start-Sleep -s 10
Write-Host "Content of app in JSON format is:"
$app
$app = $app | ConvertFrom-Json
Write-Host "Content of app after ConvertFrom-Json is:"
$app
""
""
""
Write-Host "Content of app.appId is:"
$app.appId
""
""
""
Write-Host "Content of clientId is:"
$clientId = $app.appId
$clientId
""
""
""
Write-host "Append or overwrite an application's password (autogenerated):"
$password = az ad app credential reset --id $clientId
$password = $password | ConvertFrom-Json
$appSecret = $password.password
""
""
""
# wait for the AAD app to be created or the script will fail later on
"Waiting for the app to be fully provisioned..."
Start-Sleep -Seconds 10
""
""
""
Write-Host "az ad sp create - Create Service Principal"
$spObj = az ad sp create --id $app.appId
""
""
""
Write-Host "Waiting for the SP to be provisioned..." 
Start-Sleep -s 15
Write-Host "spObj"
$spObj
$spObjConv = $spObj | ConvertFrom-Json
""
""
""
Write-Host "spObjConv.objectId"
$spObjConv.objectId
""
""
""
# Grants after the SP is created:
Write-Host "Grants once the SP is created: az ad app permission grant"
az ad app permission grant --id $app.appId --api 00000000-0000-0000-0000-000000000000
""
""
""
Write-Host "az ad app permission list --id"
az ad app permission list --id $app.appId
""
""
""
Write-Host "setup gobal variable needed by the next task: clientId"
Write-Host "##vso[task.setvariable variable=clientId]$clientId"
Write-Host "setup output variable needed by the next stage: clientIdOutput"
Write-Host "##vso[task.setvariable variable=clientIdOutput;isOutput=true]$clientId"
Write-Host "##vso[task.setvariable variable=appRegisterTimestampOutput;isOutput=true]$appRegisterTimestamp"
Write-Host "##vso[task.setvariable variable=spName]$spName"
Write-Host "##vso[task.setvariable variable=spNameOutput;isOutput=true]$spName"
Write-Host "setup gobal variable needed by the next task: appSecret/clientSecret"
Write-Host "##vso[task.setvariable variable=appSecret]$appSecret"
Write-Host "setup output variable needed by the next stage: appSecretOutput"
Write-Host "##vso[task.setvariable variable=appSecretOutput;isOutput=true]$appSecret"


















