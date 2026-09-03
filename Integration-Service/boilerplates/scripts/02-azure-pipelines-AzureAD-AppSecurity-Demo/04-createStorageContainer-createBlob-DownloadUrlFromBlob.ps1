# How to query Azure resources using the Azure CLI:
# https://argonsys.com/microsoft-cloud/library/how-to-query-azure-resources-using-the-azure-cli/

# https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-steps
# Azure built-in roles
# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-queue-data-reader-preview
# Storage - Reader and Data Access : 
#   Lets you view everything but will not let you delete or create a storage account or contained resource. 
#   It will also allow read/write access to all data contained in a storage account via access to storage account keys.
#   00000000-0000-0000-0000-000000000000
# Storage Blob Data Reader	
#   Read and list Azure Storage containers and blobs. To learn which actions are required for a given data operation, see Permissions for calling blob and queue data operations.	
#   00000000-0000-0000-0000-000000000000


Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup 
$rgLocation=$args[1]
write-host $rgLocation 
$storageAccount=$args[2]
write-host $storageAccount
$storageContainerName=$args[3]
write-host $storageContainerName
$blobName=$args[4]
write-host $blobName
$storageAccountTags=$args[5]
write-host $storageAccountTags
$spName=$args[6]
write-host $spName

#################
# Start of script
#################

######################################################################################################
# Installed powershell modules:
# https://github.com/actions/virtual-environments/blob/main/images/win/Windows2022-Readme.md
#Write-Host "List Installed Powershell Modules"
#Get-Module -ListAvailable
######################################################################################################

Write-Host "Retrieve the ObjectId of our Storage Account:"
$objectIdStorageAccount = az storage account show -n $storageAccount -g $resourceGroup --query "id" -o tsv
$objectIdStorageAccount
" "
" "
" "
Write-Host "Update storage account by adding tags on it"
az storage account update --name $storageAccount --resource-group $resourceGroup --tags $storageAccountTags
" "
" "
" "
Write-Host "Retrieve storage account keys list"
az storage account keys list -n $storageAccount -g $resourceGroup --output table
" "
" "
" "
# https://stackoverflow.com/questions/44438984/generating-sas-to-access-azure-storage
Write-Host "Generate Storage Account Connection String"
$storageAccountConnectionString = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv
$storageAccountConnectionString
" "
" "
" "
Write-Host "Generate SAS within storage container"
$end = date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'
$sasToken = az storage container generate-sas --connection-string $storageAccountConnectionString -n $storageContainerName --permissions rl --expiry $end --output tsv
" "
" "
" "
Write-Host "Create a Container on Storage account: az storage container create"
# Create a storage container in a storage account and allow public read access for blobs.
# https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-managed-identity
# Azure Blob Storage supports Azure Active Directory (Azure AD) authentication with managed identities for Azure resources. 
# Managed identities for Azure resources can authorize access to blob data using Azure AD credentials from applications running in Azure virtual machines (VMs), function apps, 
# virtual machine scale sets, and other services. By using managed identities for Azure resources together with Azure AD authentication, 
# you can avoid storing credentials with your applications that run in the cloud.
# Assign an RBAC role to a managed identity
# https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-managed-identity
# https://docs.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=azure-cli 
# https://www.c-sharpcorner.com/article/azure-storage-account-using-azure-cli/

# By default, container data is private ("off") to the account owner. Use "blob" to allow public read access for blobs. Use "container" to allow public read and list access to the entire container. 
# You can configure the --public-access using az storage container set-permission -n CONTAINER_NAME --public-access blob/container/off.

az storage container create --resource-group $resourceGroup --account-name $storageAccount --name $storageContainerName --connection-string $storageAccountConnectionString --sas-token $sasToken --public-access blob

# This other one works as well, since sasToken is already created and assignd to the same container name:
#az storage container create --resource-group $resourceGroup --account-name $storageAccount --name $storageContainerName --connection-string $storageAccountConnectionString --public-access blob --debug
" "
" "
" "
# Public access can be modified:
#az storage container set-permission -n $storageContainerName --public-access blob/container/off
" "
" "
" "
Write-Host "create demo.txt file"
New-Item -Name demo.txt -ItemType File
" "
" "
" "
# https://docs.microsoft.com/en-us/cli/azure/storage/blob
# Upload a blob in Container
Write-Host "Upload a blob in Container"
az storage blob upload --account-name $storageAccount --container-name $storageContainerName --name $blobName --file demo.txt --connection-string $storageAccountConnectionString --overwrite true
#--overwrite true  # in preview and under development
" "
" "
" "
# Upload a string to a blob.
Write-Host "Upload a string to a blob"
az storage blob upload --data "test string by enterprise" -c $storageContainerName -n $blobName --account-name $storageAccount --connection-string $storageAccountConnectionString --overwrite true
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
Write-Host "URL with 1st sas token (expires after 30 min):"
$url1 = $blobUrl+'?'+$sasToken     
Write-Output $url1


##################################################################################################
# SAS Token 2
# Write-Host "az storage blob generate-sas - Generate a shared access signature for the blob. (autogenerated)"
# $endToken2 = date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ' # 'date' command in Windows Server running in our DevOps Azure Pipeline
# $sasToken2 = az storage blob generate-sas --connection-string $storageAccountConnectionString --account-name $storageAccount --container-name $storageContainerName --expiry $endToken2 --name $blobName --permissions r --https-only --blob-url $blobUrl --output tsv
# Write-Output $sasToken2
# " "
# " "
# " "
# Write-Host "URL with 2nd sas token (expires after 30 min):"
# $url2 = $blobUrl+'?'+$sasToken2
# Write-Output $url2
##################################################################################################



############################################################################################################################################################################################################################################
# More SAS Token Examples
# A shared access signature (SAS) is a URI that grants restricted access to an Azure Storage blob. Use it when you want to grant access to storage account resources for a specific time range without sharing your storage account key.
# az storage blob generate-sas: Generate a shared access signature for the blob.

# Write-Host "az storage blob generate-sas - Generate a sas token for a blob with ip range specified."
# $end = date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'  # 'date' command in Windows Server running in our DevOps Azure Pipeline
# az storage blob generate-sas -c myycontainer -n MyBlob --ip "127.0.0.1-127.0.0.1" --permissions r --expiry $end --https-only

# $end= date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'
# az storage blob generate-sas -c myycontainer -n MyBlob --permissions r --expiry $end --https-only

# $end= date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'
# az storage blob generate-sas -c myycontainer -n MyBlob --ip "127.0.0.1-127.0.0.1" --permissions r --expiry $end --https-only

# az storage blob generate-sas --account-key 00000000 --account-name MyStorageAccount --container-name mycontainer --expiry 2000-01-01T00:00:00Z --name MyBlob --permissions r
############################################################################################################################################################################################################################################



############################################################################################################################################################################################################################################
# Blob Index Tags to manage and find data on Azure Blob Storage
# https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/storage/blobs/storage-blob-index-how-to.md
# https://docs.microsoft.com/en-us/cli/azure/storage/blob/tag
#
# #   ERROR: The command requires the extension storage-blob-preview. Unable to prompt for extension install confirmation as no tty available. 
# #   Run 'az config set extension.use_dynamic_install=yes_without_prompt' to allow installing extensions without prompt.
# Write-Host "az config set extension.use_dynamic_install"
# az config set extension.use_dynamic_install=yes_without_prompt
# ""
# ""
# ""
# Write-Host "az storage blob tag set:"
# # To set the tags of a blob, use the az storage blob tag set command. Set the --name parameter to the name of the blob, and set the --tags parameter to a collection of name and value pairs.
# az storage blob tag set --account-name $storageAccount --container-name $storageContainerName --name $blobName  --tags project=JL
# ""
# ""
# ""
# Write-Host "az storage blob tag list:"
# # To get the tags of a blob, use the az storage blob tag list command and set the --name parameter to the name of the blob.
# az storage blob tag list --account-name $storageAccount --container-name $storageContainerName --name $blobName
# ""
# ""
# ""
