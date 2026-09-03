# https://cann0nf0dder.wordpress.com/2000/01/01/az-cli-putting-message-on-a-storage-queue-not-a-valid-base-64-string/
# https://systemweakness.com/exploiting-azure-queue-storage-unexpired-sas-token-with-excessive-permission-e0f47475cb8d
# Azure Queue Storage Tutorial: https://www.youtube.com/watch?v=JQ6KhjU5Zsg
# https://github.com/Azure/azure-cli-samples/blob/master/storage/queues.md

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup
$rgLocation = $args[1]
write-host $rgLocation
$storageAccount = $args[2]
write-host $storageAccount
$storageAccountTags = $args[3]
write-host $storageAccountTags
$upnName = $args[4]
Write-Host $upnName
$centerName = $args[5]
write-host $centerName

####################################################################################################################################################
# Start of script Example: ./06-storageMessage-START.ps1 rg-app-core-client-anon northeurope stapp-coreclient-anon env=client-anon inaki cloud-admin@example.com enterprise
####################################################################################################################################################
""
""
""
$a, $b = $upnName.Split("@")
$queueName = $a + '-' + $centerName
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
##########################################################################
# Put START Message in Storage Queue
##########################################################################
Write-Host "Add a new message to the back of the message queue:"
# $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.ms"   # Miliseconds: 2022-05-17T12:22:34.2234
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"  # 2022-05-17T12:23:01
$timestamp
""
""
""
###########################################################################################################################################################################
# OPTION 1: Based on ConvertTo-Json - AVOID THIS when possible, since variables with special chars (like the ones we can find in the URL) are converted to ASCII codes!!
#           This solution could even have a different outcome when running in a laptop VS running in DevOps Azure.
# $message = "{""upn"":""$upnName"",""timestamp"":""$timestamp""}"
# Write-Host "Message Content:"
# $message
# $message = $message | ConvertTo-Json
# ""
# ""
# ""
###########################################################################################################################################################################
#$message = "{\""type\"":\""integration-service_GENERATION\"",\""upn\"":\""$upnName\"",\""timestamp\"":\""$timestamp\""}" # THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP! (devops technician)
$message = "{\""type\"":\""integration-service_GENERATION\"",\""params\"":{\""upn\"":\""$upnName\"",\""timestamp\"":\""$timestamp\""}}" # Nested Json required by integration-service Devel Team. THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP! (devops technician)
# $message = '{\"type\":\"integration-service_GENERATION\",\"params\":{\"upn\":\"' + $upnName + '\",\"timestamp\":\"' + $timestamp + '\"}}' # This is the solution written by integration-service Developer
Write-Host "Message Content:"
$message
""
""
""
write-host "az storage message put:"
az storage message put --content $message --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --time-to-live 86400 #--debug --verbose
