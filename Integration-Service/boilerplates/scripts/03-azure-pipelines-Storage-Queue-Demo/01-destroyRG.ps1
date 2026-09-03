####################################################################################################################
# Variables can be defined here or within the YAML based declarative pipeline (calling this script with parameters)
####################################################################################################################

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup 
$storageAccount=$args[1]
write-host $storageAccount
$upnName=$args[2]
Write-Host $upnName
$centerName=$args[3]
write-host $centerName

#################
# Start of script
#################
""
""
""
# $a, $b = $upnName.Split("@")
# $queueName = $a+'-'+$centerName  
# $queueName = $queueName.ToLower()  # Otherwise we get an ErrorCode:InvalidResourceName
# Write-Host "Queue Name: $queueName"
# ""
# ""
# ""
# Write-Host "Retrieve the ObjectId of our Storage Account:"
# $objectIdStorageAccount = az storage account show -n $storageAccount -g $resourceGroup --query "id" -o tsv
# $objectIdStorageAccount
# " "
# " "
# " "
# # Generate connection-string
# # https://stackoverflow.com/questions/44438984/generating-sas-to-access-azure-storage
# Write-Host "Generate Storage Account Connection String"
# $storageAccountConnectionString = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv
# $storageAccountConnectionString
# " "
# " "
# " "
# Write-Host "Checking if Storage Queue already exists:" 
# $storageQueueExists = az storage queue exists -n $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString
# if ($storageQueueExists) {
#     Write-Host "Delete existing Storage Queue on Storage account: az storage queue delete"
# 	az storage queue delete -n $queueName --fail-not-exist --account-name $storageAccount
#     " "
#     " "
#     " "
#     Write-Host "Waiting for the storage queue to be removed..." 
#     Start-Sleep -s 5
# }
# ""
# ""
# ""
Write-Host "Check if RG exists"
$rgExists = az group exists --name $resourceGroup

if ("true" -eq $rgExists) {
	Write-Host "Destroy existing RG"
	az group delete --yes -n $resourceGroup
}



