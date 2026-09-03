# https://cann0nf0dder.wordpress.com/2000/01/01/az-cli-putting-message-on-a-storage-queue-not-a-valid-base-64-string/

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup
$storageAccount = $args[1]
write-host $storageAccount
$upnName = $args[2]
Write-Host $upnName
$centerName = $args[3]
write-host $centerName
$BlobFileDownloadUrl = $args[4]
write-host $BlobFileDownloadUrl


############################################################################################################################################################################
# EXAMPLES OF VALID MESSAGES TO BE USED BY 'AZ STORAGE MESSAGE PUT':
# $message = "{""upn"":""cloud-user@enterprisecom"",""timestamp"":""2022-05-18T18:45:09""}"
# $message = "{\""upn\"":\""cloud-admin@example.com\"",\""timestamp\"":\""2022-05-18T18:45:09\""}"
# $message = "{\""upn\"":\""cloud-admin@example.com\"",\""url\"":\""https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-18h-46m-55s-4655ms?se=2022-05-18T19%3A27Z&sp=rl&sv=2021-04-10&sr=c&sig=V%2B%2BzqLzrid6n2Ftzz/SuB68cdvJ05lBOfMk4A63q3JY%3D\"",\""timestamp\"":\""2022-05-18T18:59:15\""}"
############################################################################################################################################################################

#################
# Start of script
#################
""
""
""
$a, $b = $upnName.Split("@")
$queueName = $a + '-' + $centerName
$queueName = $queueName.ToLower()  # Otherwise we get an ErrorCode:InvalidResourceName
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
Write-Host "Add a new message to the back of the message queue"
" "
" "
" "
write-host "Timestamp:"
# $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.ms"   # Miliseconds: 2022-05-17T12:22:34.2234
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"  # 2022-05-17T12:23:01
$timestamp
""
""
""
#$message = "{\""type\"":\""integration-service_INSTALLATION\"",\""upn\"":\""$upnName\"",\""url\"":\""$BlobFileDownloadUrl\"",\""timestamp\"":\""$timestamp\""}"     # THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP!  (devops technician)
$message = "{\""type\"":\""integration-service_GENERATION\"",\""params\"":{\""upn\"":\""$upnName\"",\""timestamp\"":\""$timestamp\""},\""body\"":{\""url\"":\""$BlobFileDownloadUrl\""}}" # Nested Json required by integration-service Devel Team. THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP! (devops technician)
#$message = ('{\"type\":\"integration-service_INSTALLATION\",\"params\":{\"upn\":\"' + $upnName + '\",\"timestamp\":\"' + $timestamp + '\"}, \"body\":{\"url\": \""' + $BlobFileDownloadUrl + '\""}}') # This is the solution written by integration-service Developer
Write-Host "Message Content:"
$message
""
""
""
write-host "az storage message put:"
az storage message put --content $message --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --time-to-live 86400 #--debug --verbose
