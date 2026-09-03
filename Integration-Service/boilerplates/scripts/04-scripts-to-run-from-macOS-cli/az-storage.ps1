# https://zimmergren.net/azure-cli-in-vscode/
  
$serviceConnection= 'svccon-integration-service-dev'
$appName= 'appr-integration-service-OnPrem-test'
$appsecret= 'enterpriseDemoStuff1!'
$spName= $appName
$tenant= '00000000-0000-0000-0000-000000000000'
$resourceGroup= 'rg-integration-onpremise-dev'
$rgLocation= 'northeurope'
$storageAccount= 'st-integration-dev'
$storageContainerName= 'sgcontainerintegration-servicedev1'
$blobName= 'blob1'
$storageAccountTags= 'env=dev'
$roleName= 'Storage Blob Data Reader'



#################
# SCRIPT:
################

Write-Host "Grab current subscription ID"
$subscriptionId = az account show --query "id" -o tsv
$subscriptionId
" "
" "
" "
# Scope:
#   - By default: Subscription Scope
#   - Resource Group Scope: /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-integration-onpremise-dev
#   - VM scope
#   - Container scope
#   - etc
#
# RG Scope:
$scopeLevel= "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"
# Container Scope:
#$scopeLevel= "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount/blobServices/default/containers/$storageContainerName"


Write-Host "List Storage Accounts:"
az storage account list -g $resourceGroup 
" "
" "
" "
Write-Host "Retrieve the ObjectId of our Storage Account:"
$objectIdStorageAccount = az storage account show -n $storageAccount -g $resourceGroup --query "id" -o tsv
$objectIdStorageAccount
" "
" "
" "
Write-Host "Generate Storage Account Connection String"
$storageAccountConnectionString = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv
$storageAccountConnectionString
" "
" "
" "
Write-Host "Checking if container already exists:"
$containerExists = az storage container exists --account-name $storageContainerName --name $storageContainerName --connection-string $storageAccountConnectionString
if ($containerExists) {
    Write-Host "Delete existing Container on Storage account: az storage container delete"
    az storage container delete --account-name $storageContainerName --name $storageContainerName --connection-string $storageAccountConnectionString
    " "
    " "
    " "
    Write-Host "Waiting for the container to be removed..." 
    Start-Sleep -s 40
}

" "
" "
" "
# Role Assignment ID
$roleAssignmentId = az role assignment list --assignee $spObjectId --scope $scopeLevel --role $roleName --query "[0].id" -o tsv 
$roleAssignmentId
" "
" "
" "
# Role Assignment Delete:
if (-Not [string]::IsNullOrEmpty($roleAssignmentId)) {
    Write-Host "Delete existing Role Assignment"
    az role assignment delete --role $roleName --resource-group $resourceGroup --assignee $spObjectId --yes 
    #[--include-inherited]
}
" "
" "
" "
##generate sas within storage container
Write-Host "Generate SAS within storage container"
#$end = date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'
$end = date -v+30M '+%Y-%m-%dT%H:%MZ'  # UTC datetime Y-m-d'T'H:M'Z # macOS date
$sasToken = az storage container generate-sas --connection-string $storageAccountConnectionString -n $storageContainerName --permissions rl --expiry $end --output tsv
Write-Output $sasToken
" "
" "
" "
Write-Host "Create a Container on Storage account: az storage container create"
az storage container create --resource-group $resourceGroup --account-name $storageAccount --name $storageContainerName --connection-string $storageAccountConnectionString --sas-token $sasToken --public-access blob
" "
" "
" "
Write-Host "Waiting for the container to be created..." 
Start-Sleep -s 40
" "
" "
" "
Write-Host "az storage container list"
az storage container list --account-name $storageAccount --connection-string $storageAccountConnectionString
" "
" "
" "
Write-Host "create demo.txt file"
New-Item -Name demo.txt -ItemType File
" "
" "
" "
Write-Host "Upload a blob in Container"
az storage blob upload --account-name $storageAccount --container-name $storageContainerName --name $blobName --file demo.txt --connection-string $storageAccountConnectionString --overwrite true
" "
" "
" "
Write-Host "Upload a string to a blob"
az storage blob upload --data "test string by enterprise" -c $storageContainerName -n $blobName --account-name $storageAccount --connection-string $storageAccountConnectionString --overwrite true
" "
" "
" "
Write-Host "remove demo.txt file"
Remove-Item demo.txt
" "
" "
" "
Write-Host "az storage blob list"
az storage blob list --account-name $storageAccount --container-name $storageContainerName --connection-string $storageAccountConnectionString
" "
" "
" "
Write-Host "az storage blob url"
$blobUrl = az storage blob url --account-name $storageAccount --container-name $storageContainerName --connection-string $storageAccountConnectionString --name $blobName --output tsv
Write-Output $blobUrl
" "
" "
" "
Write-Host "Grab SP objectId"
$spObjectId = az ad sp list --query "[?appDisplayName=='appr-integration-service-OnPrem-test'].objectId | [0]" --all
$spObjectId
" "
" "
" "
Write-Host "URL with 1st sas token (expires after 30 min):"
$url1 = $blobUrl+'?'+$sasToken
Write-Output $url1
" "
" "
" "


" "
" "
" "
Write-Host "az role assignment:"
###################################################
# OK (basic role assignment with simple condition)
###################################################

az role assignment create --role $roleName --scope $scopeLevel --assignee-object-id $spObjectId `
--assignee-principal-type ServicePrincipal --description "Role assignment foo to check on bar" `
--condition-version "2.0" `
--condition "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:Name] stringEquals 'blob1'" 


###################################################################################################################
# NOK: 
# Resource attribute Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:project<$> is not valid.
###################################################################################################################

#az role assignment create --role $roleName --scope $scopeLevel --assignee-object-id $spObjectId `
#--assignee-principal-type ServicePrincipal --description "Role assignment foo to check on bar" `
#--condition-version "2.0" `
#--condition "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:project<$key_case_sensitive$>] StringEqualsIgnoreCase 'JL'"


######################################################################################################################
# Complete ABAC condition grabbed from Azure UI when setting this up manually (in theory to be used programmatically)
######################################################################################################################
#--condition ((!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND SubOperationMatches{'Blob.Read.WithTagConditions'})) OR (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:project<$key_case_sensitive$>] StringEqualsIgnoreCase 'JL')) 


##############################
# OK according to below refs:
##############################
# https://techcommunity.microsoft.com/t5/azure-active-directory-identity/introducing-azure-ad-custom-security-attributes/ba-p/2147068
# https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-abac-examples?toc=/azure/role-based-access-control/toc.json
# https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-powershell
# $condition = "((!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND SubOperationMatches{'Blob.Read.WithTagConditions'})) OR (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:Project<`$key_case_sensitive`$>] StringEquals 'Cascade'))"
# $testRa = Get-AzRoleAssignment -Scope $scope -RoleDefinitionName $roleDefinitionName -ObjectId $userObjectID
# $testRa.Condition = $condition
# $testRa.ConditionVersion = "2.0"
# Set-AzRoleAssignment -InputObject $testRa -PassThru


#Write-Host "Installing Az.Resources Module: Azure Resource Manager Cmdlets (with i.e. Set-AzRoleAssignment):"
#install-module -Name Az.Resources -Scope CurrentUser -Force
#install-module -Name Az.Resources -Scope CurrentUser -SkipPublisherCheck -Force

#install-module -Name Az.Resources -SkipPublisherCheck -Force
#https://docs.microsoft.com/en-us/powershell/module/az.resources/


#$roleDefinitionName= $roleName
# $condition = "((!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND SubOperationMatches{'Blob.Read.WithTagConditions'})) OR (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:project<$key_case_sensitive$>] StringEqualsIgnoreCase 'JL'))"
# $testRa = Get-AzRoleAssignment -Scope $scope -RoleDefinitionName $roleDefinitionName -ObjectId $spObjectId
# $testRa.Condition = $condition
# $testRa.ConditionVersion = "2.0"
# Set-AzRoleAssignment -InputObject $testRa -PassThru




# Connect-MgGraph -Scopes "CustomSecAttributeAssignment.ReadWrite.All","CustomSecAttributeDefinition.ReadWrite.All"
# $spObjectId = az ad sp list --query "[?appDisplayName=='appr-integration-service-OnPrem-test'].objectId | [0]" --all -o tsv
# $spObjectId
# $roleName= 'Storage Blob Data Reader'
# Update-MgServicePrincipalAppRoleAssignedTo -AppRoleAssignmentId $roleName -ServicePrincipalId $spObjectId
