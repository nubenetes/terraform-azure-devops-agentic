
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

Write-Host "Create Resource Group"
az group create -l $rgLocation -n $resourceGroup --tags $storageAccountTags 
#--managed-by $app.appId
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
Write-Host "Create Storage Account"
az storage account create -n $storageAccount -g $resourceGroup -l $rgLocation --sku Standard_LRS 
" "
" "
" "
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

