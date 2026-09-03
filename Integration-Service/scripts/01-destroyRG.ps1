####################################################################################################################
# Variables can be defined here or within the YAML based declarative pipeline (calling this script with parameters)
####################################################################################################################

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName
$resourceGroup=$args[1]
write-host $resourceGroup 
$rgLocation=$args[2]
write-host $rgLocation 
$storageAccountTags=$args[3]
write-host $storageAccountTags
$storageAccount=$args[4]
write-host $storageAccount
$storageContainerName=$args[5]
write-host $storageContainerName

#################
# Start of script
#################


# Write-Host "Retrieve the ObjectId of our Storage Account:"
# $objectIdStorageAccount = az storage account show -n $storageAccount -g $resourceGroup --query "id" -o tsv
# $objectIdStorageAccount
# " "
# " "
# " "

# Generate connection-string
# https://stackoverflow.com/questions/44438984/generating-sas-to-access-azure-storage
# Write-Host "Generate Storage Account Connection String"
# $storageAccountConnectionString = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv
# $storageAccountConnectionString
# " "
# " "
# " "
# Write-Host "Checking if container already exists:"
# $containerExists = az storage container exists --account-name $storageContainerName --name $storageContainerName --connection-string $storageAccountConnectionString
# if ($containerExists) {
#     Write-Host "Delete existing Container on Storage account: az storage container delete"
#     az storage container delete --account-name $storageContainerName --name $storageContainerName --connection-string $storageAccountConnectionString
#     " "
#     " "
#     " "
#     Write-Host "Waiting for the container to be removed..." 
#     Start-Sleep -s 40
# }


Write-Host "Check if RG exists"
$rgExists = az group exists --name $resourceGroup

if ("true" -eq $rgExists) {
	Write-Host "Destroy existing RG"
	az group delete --yes -n $resourceGroup
}



