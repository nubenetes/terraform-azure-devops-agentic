
Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$resourceGroup=$args[0]
write-host $resourceGroup 
$storageAccount=$args[1]
write-host $storageAccount
$upnName=$args[2]
Write-Host $upnName
$centerName=$args[3]
write-host $centerName
$BlobFileDownloadUrl=$args[4]
Write-Host $BlobFileDownloadUrl

#################
# Start of script
#################
## Enable debug logging
$DebugPreference = 'Continue'
""
""
""
$a, $b = $upnName.Split("@")
$queueName = $a+'-'+$centerName  
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
Write-Host "Add a new message to the back of the message queue:"
# $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.ms"   # Miliseconds: 2022-05-17T12:22:34.2234
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"  # 2022-05-17T12:23:01
""
""
""
###############################################################################################################################################################################
# OPTION 1: Based on ConvertTo-Json - AVOID THIS when possible, since variables with special chars (like the ones we can find in the URL) are converted to ASCII codes!!
#           This solution could even have a different outcome when running in a laptop VS running in DevOps Azure.
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# Write-Host "Message Content:"
# $message
# $message = $message | ConvertTo-Json
# ""
# ""
# ""
# Write-Host "Message with JSON Content:"
# $message
# ""
# ""
# ""
###############################################################################################################################################################################

# OPTION 2: BEST SOLUTION! - Use the following string format to deal with special chars in variables like $BlobFileDownloadUr :
$message = "{\""upn\"":\""$upnName\"",\""url\"":\""$BlobFileDownloadUrl\"",\""timestamp\"":\""$timestamp\""}"     # THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP!
Write-Host "Message Content:"
$message
""
""
""
write-host "az storage message put:"
az storage message put --content $message --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --time-to-live 86400 #--debug --verbose









