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


#$appName = "appr-integration-service-OnPrem-test"
#$secret = "enterpriseDemoStuff1!"
#$spName = "appr-integration-service-OnPrem-test"

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName
$secret=$args[1]
write-host $secret
$spName=$args[2]
write-host $spName
$rgLocation=$args[3] 
write-host $rgLocation
$resourceGroup=$args[4] 
write-host $resourceGroup
$storageAccountTags=$args[5] 
write-host $storageAccountTags

#################
# Start of script
#################

## Upgrading AZ CLI
## Upgrading AZ CLI - Option 1:

	# Install Azure CLI beta
	# https://docs.microsoft.com/en-us/cli/azure/microsoft-graph-migration?tabs=powershell
	#Write-Host "Install Azure CLI beta"
	#python -m pip install --upgrade pip
	#pip install --extra-index-url https://azurecliprod.blob.core.windows.net/beta/simple/ azure-cli

	#Write-Host "Update Azure CLI beta"
	#pip install --extra-index-url https://azurecliprod.blob.core.windows.net/beta/simple/ --upgrade azure-cli

## Upgrading AZ CLI - Option 2 (do not enable this, a pipeline with this command becomes a zombie job):

	#Write-Host "Upgrading AZ CLI: az upgrade --yes"
	#az upgrade --yes
	#	WARNING: This command is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
	#	WARNING: Your current Azure CLI version is 2.34.1. It will be updated to 2.35.0.
	#	WARNING: Updating Azure CLI with MSI from https://aka.ms/installazurecliwindows


# Adding a Microsoft Graph "User-Read" of type "Delegated permission" (on behalf of the client app) to our registered client app: 
Write-Host "az ad sp list; az ad sp show"
$graphId = az ad sp list --query "[?appDisplayName=='Microsoft Graph'].appId | [0]" --all
$userRead = az ad sp show --id $graphId --query "oauth2Permissions[?value=='User.Read'].id | [0]"

Write-Host "resources var"
$resources = @"
[{ "resourceAppId": $graphId, "resourceAccess": [{"id": $userRead,"type": "Scope"}]}]
"@ | ConvertTo-Json

"Creating AAD app $appName..."
Write-Host "az ad app create"
$app = az ad app create --display-name $appName --password $secret --required-resource-accesses $resources | ConvertFrom-Json
#specify either --password or --key-value, but not both.
#az ad sp create-for-rbac -n "MyApp" --role Contributor --scopes /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup1} /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup2}

# Errors I get when running this pipeline with latest az cli (after a pip install):
#ERROR: Failed to parse JSON: [{ "resourceAppId": "00000000-0000-0000-0000-000000000000", "resourceAccess": [{"id": ,"type": "Scope"}]}]
#Error detail: Expecting value: line 1 column 87 (char 86)
#The JSON may have been parsed by the shell. See https://docs.microsoft.com/cli/azure/use-cli-effectively#use-quotation-marks-in-arguments
#PowerShell requires additional quoting rules. See https://github.com/Azure/azure-cli/blob/dev/doc/quoting-issues-with-powershell.md

Write-Host "Waiting for the app to be provisioned..." 
Start-Sleep -s 10
Write-Host "Content of app is:"
$app

Write-Host "Content of app.appId is:"
$app.appId

# wait for the AAD app to be created or the script will fail later on
"Waiting for the app to be fully provisioned..."
Start-Sleep -Seconds 10

# Finding the Correct Permissions for a Microsoft or Azure Active Directory Graph Call
# https://docs.microsoft.com/en-us/archive/blogs/aaddevsup/finding-the-correct-permissions-for-a-microsoft-or-azure-active-directory-graph-call
# Remember: API permissions can be setup at the "Scope" level or at the "Role" level
#           ad ad app permission add --id ... --api ... --api-permissions ...=Scope   ----> Delegated Permissions (OAuth2Permission)
#           ad ad app permission add --id ... --api ... --api-permissions ...=Role    ----> Application Role permissions (the ones we need)
#
#
# https://docs.microsoft.com/en-us/cli/azure/ad/app/permission?view=azure-cli-latest#az-ad-app-permission-add
# To get available permissions of the resource app, run (Microsoft Graph):
#    az ad sp show --id 00000000-0000-0000-0000-000000000000
# Application permissions under the appRoles property correspond to Role in --api-permissions. 
# Delegated permissions under the oauth2Permissions property correspond to Scope in --api-permissions.
#
# https://docs.microsoft.com/en-us/graph/permissions-reference


Write-Host "az ad app permission add: Add Microsoft Graph application permission - Application.ReadWrite.All (Read and write all applications)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission - Directory.ReadWrite.All (Read and write directory data)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission - Application.ReadWrite.OwnedBy (Manage apps that this app creates or owns)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission -  CustomSecAttributeDefinition.ReadWrite.All (Read and write custom security attribute definitions)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission - CustomSecAttributeAssignment.ReadWrite.All (Read and write custom security attribute assignments)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission - AppRoleAssignment.ReadWrite.All (Manage app permission grants and app role assignments)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role
Write-Host "az ad app permission add: Add Microsoft Graph application permission - ServicePrincipalEndpoint.ReadWrite.All (Allows the app to update service principal endpoints)"
az ad app permission add --id $app.appId --api 00000000-0000-0000-0000-000000000000 --api-permissions 00000000-0000-0000-0000-000000000000=Role


Write-Host "az ad sp create - Create Service Principal"
$spObj = az ad sp create --id $app.appId

Write-Host "Waiting for the SP to be provisioned..." 
Start-Sleep -s 15
Write-Host "spObj"
$spObj

$spObjConv = $spObj | ConvertFrom-Json

Write-Host "spObjConv.objectId"
$spObjConv.objectId

# Grants after the SP is created:
Write-Host "Grants once the SP is created: az ad app permission grant"
az ad app permission grant --id $app.appId --api 00000000-0000-0000-0000-000000000000

Write-Host "az ad app permission list --id"
az ad app permission list --id $app.appId

Write-Host "==========================================================================================================="
Write-Host "Grant Application & Delegated permissions through admin-consent. You must login as a global administrator. "
Write-Host "We cannot do this via this script run by a pipeline (unattended)"
Write-Host ""
Write-Host ""
Write-Host "Please run manually the following AZ CLI as an Azure Global Administrator:"
Write-Host ""
Write-Host "az ad app permission admin-consent --id $($app.appId)"
Write-Host "==========================================================================================================="


Write-Host "Create Resource Group"
az group create -l $rgLocation -n $resourceGroup --tags $storageAccountTags --managed-by $app.appId
































