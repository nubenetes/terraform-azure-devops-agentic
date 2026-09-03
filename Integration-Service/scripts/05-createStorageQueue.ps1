
Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup 
$rgLocation=$args[1]
write-host $rgLocation 
$storageAccount=$args[2]
write-host $storageAccount
$storageAccountTags=$args[3]
write-host $storageAccountTags
$upnName=$args[4]
Write-Host $upnName
$centerName=$args[5]
write-host $centerName

#################
# Start of script
#################

""
""
""
$a, $b = $upnName.Split("@")
$queueName = $a+'-'+$centerName 
$queueName = $queueName.ToLower() # Otherwise we get an ErrorCode:InvalidResourceName
Write-Host "Queue Name: $queueName"
""
""
""
# https://stackoverflow.com/questions/44438984/generating-sas-to-access-azure-storage
Write-Host "Generate Storage Account Connection String"
$storageAccountConnectionString = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv
$storageAccountConnectionString
" "
" "
" "
Write-Host "Create a Storage Queue on Storage account: az storage queue create"
az storage queue create -n $queueName --metadata key1=value1 key2=value2 --account-name $storageAccount --connection-string $storageAccountConnectionString
""
""
""
Write-Host "Waiting for the Storage Queue to be created.." 
Start-Sleep -s 10

#Write-Host "List queues in a storage account:"
#az storage queue list --account-name $storageAccount --connection-string $storageAccountConnectionString





