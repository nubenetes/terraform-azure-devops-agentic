# https://github.com/Azure/azure-cli-samples/blob/master/storage/queues.md

$upnName = 'cloud-admin@example.com'
$resourceGroup = 'dev-appcResourceGroup'
$storageAccount = 'dev-appenterprisesa'
$centerName = 'enterprise'


#################
# Start of script
#################

###### Select Azure Subscription first:
# We need "enterprise Example-Dev-Subscription"
write-host "list available subscriptions:"
az account list --output table
""
""
""
write-host "get the current default subscription using show"
az account show --output table
""
""
""
write-host "Change the active subscription"
az account set --subscription "enterprise Example-Dev-Subscription"
""
""
""
write-host "get the current default subscription using show"
az account show --output table
""
""
""
write-host "Start of Script:"
$a, $b = $upnName.Split("@")
$queueName = $a+'-'+$centerName 
$queueName = $queueName.ToLower() # Otherwise we get an ErrorCode:InvalidResourceName
Write-Host "Queue Name: $queueName"
""
""
""
# https://stackoverflow.com/questions/44438984/generating-sas-to-access-azure-storage
# This is caused by the automatic character escape feature of Convertto-Json and it affects several symbols such as <>\'&
$storageAccountConnectionString = az storage account show-connection-string --name dev-appenterprisesa --resource-group $resourceGroup --output tsv  
$storageAccountConnectionString

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

$message = "{\""upn\"":\""$upnName\"",\""url\"":\""$BlobFileDownloadUrl\"",\""timestamp\"":\""$timestamp\""}"      # THIS IS THE RIGHT SOLUTION FOR BOTH DEVOPS AZURE AND MY LAPTOP!
Write-Host "Message Content:"
$message

#########################################################################################################################################
# OPTION 1 : NOK - THIS WAS WORKING FINE WITH THE OLD SHORT URLS  - we have now "\u0026" in the message queue  
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# $message = $message | ConvertTo-Json 
#
# Message Content:
# {"upn":"cloud-admin@example.com","url":"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-53m-53s-5353ms?se=2022-05-18T21%3A34Z&sp=rl&sv=2021-04-10&sr=c&sig=%2B1QbkxmYyzJZp5PbzdZDhN8nkE3Ib%2Bp4gFseHhvmLy0%3D","timestamp":"2022-05-18T21:06:24"}
#
#Write-Host "Message Content with new format:"
# "{\"upn\":\"cloud-admin@example.com\",\"url\":\"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-53m-53s-5353ms?se=2022-05-18T21%3A34Z\u0026sp=rl\u0026sv=2021-04-10\u0026sr=c\u0026sig=%2B1QbkxmYyzJZp5PbzdZDhN8nkE3Ib%2Bp4gFseHhvmLy0%3D\",\"timestamp\":\"2022-05-18T21:06:24\"}"
#
# {
#    "content": "{\"upn\":\"cloud-admin@example.com\",\"url\":\"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-53m-53s-5353ms?se=2022-05-18T21%3A34Z\\u0026sp=rl\\u0026sv=2021-04-10\\u0026sr=c\\u0026sig=%2B1QbkxmYyzJZp5PbzdZDhN8nkE3Ib%2Bp4gFseHhvmLy0%3D\",\"timestamp\":\"2022-05-18T21:06:24\"}",
#    "dequeueCount": null,
#    "expirationTime": "2022-05-19T21:06:26+00:00",
#    "id": "00000000-0000-0000-0000-000000000000",
#    "insertionTime": "2022-05-18T21:06:26+00:00",
#    "popReceipt": "AgAAAAMAAAAAAAAAkuT8Ivtq2AE=",
#    "timeNextVisible": "2022-05-18T21:06:26+00:00"
#  }
#########################################################################################################################################


#########################################################################################################################################
# OPTION 1 WAS WORKING FINE WITH THE OLD SHORT URLS  - we have now "\u0026" in the message queue  
# ISSUE FOUND WITH SPECIAL CHARS IN BLOB FILE DONWLOAD URL (when this code is run by Azure DevOps Pipeline, but WORKS WHEN TRIGGERED FROM macOS CLI)
# https://stackoverflow.com/questions/29306439/powershell-convertto-json-problem-containing-special-characters
#   This is caused by the automatic character escape feature of Convertto-Json and it affects several symbols such as <>\'&
#
# https://stackoverflow.com/questions/47779157/convertto-json-and-convertfrom-json-with-special-characters/47779605#47779605
#
#
# $fileContent | ConvertFrom-Json | ConvertTo-Json | %{
#     [Regex]::Replace($_, 
#         "\\u(?<Value>[a-zA-Z0-9]{4})", {
#             param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
#                 [System.Globalization.NumberStyles]::HexNumber))).ToString() } )}
#
#########################################################################################################################################


#########################################################################################################################################
# OPTION 2 : NOK
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# $message = $message | ConvertTo-Json | %{
#     [Regex]::Replace($_, 
#         "\\u(?<Value>[a-zA-Z0-9]{4})", {
#             param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
#                 [System.Globalization.NumberStyles]::HexNumber))).ToString() 
#         }             
#     )
# }
#Write-Host "Message Content with new format:"
# "{\"upn\":\"cloud-admin@example.com\",\"url\":\"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-14m-04s-144ms?se=2022-05-18T20%3A52Z&sp=rl&sv=2021-04-10&sr=c&sig=lvVLML1FAzMz2C2r6WhPdTifRQLVZ27P6TpGEud6Sh8%3D\",\"timestamp\":\"2022-05-18T20:24:22\"}"
# az storage message put -> FAILS !
#########################################################################################################################################


#########################################################################################################################################
# OPTION 3: NOK
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# $message = $message | ConvertTo-Json | ConvertTo-Json | %{
#     [Regex]::Replace($_, 
#         "\\u(?<Value>[a-zA-Z0-9]{4})", {
#             param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
#                 [System.Globalization.NumberStyles]::HexNumber))).ToString() 
#         }             
#     )
# }
#Write-Host "Message Content with new format:"
# "\"{\\\"upn\\\":\\\"cloud-admin@example.com\\\",\\\"url\\\":\\\"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-19h-53m-18s-5318ms?se=2022-05-18T20%3A32Z\&sp=rl\&sv=2021-04-10\&sr=c\&sig=8MQiz2hQyyV20toC9AeHkBfIEakUbybNvSOy3VbKnEA%3D\\\",\\\"timestamp\\\":\\\"2022-05-18T20:04:53\\\"}\""
#########################################################################################################################################


#########################################################################################################################################
# OPTION 4: NOK
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# $message = $message | ConvertFrom-Json | ConvertTo-Json | %{
#     [Regex]::Replace($_, 
#         "\\u(?<Value>[a-zA-Z0-9]{4})", {
#             param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
#                 [System.Globalization.NumberStyles]::HexNumber))).ToString() 
#         }             
#     )
# }
#Write-Host "Message Content with new format:"
# "{\"upn\":\"cloud-admin@example.com\",\"url\":\"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-19h-27m-09s-279ms?se=2022-05-18T20%3A05Z&sp=rl&sv=2021-04-10&sr=c&sig=Y3FXZsIJTVLXvoHNkrwWycfpvHT6d7nnDpHmlBPkL3M%3D\",\"timestamp\":\"2022-05-18T19:37:08\"}"
# az storage message put -> FAILS !
#########################################################################################################################################


#########################################################################################################################################
# OPTION 5: NOK
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
# $message = $message | ConvertTo-Json | ConvertFrom-Json | %{
#     [Regex]::Replace($_, 
#         "\\u(?<Value>[a-zA-Z0-9]{4})", {
#             param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
#                 [System.Globalization.NumberStyles]::HexNumber))).ToString() 
#         }             
#     )
# }
#Write-Host "Message Content with new format:"
# {"upn":"cloud-admin@example.com","url":"https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-30m-23s-3023ms?se=2022-05-18T21%3A08Z&sp=rl&sv=2021-04-10&sr=c&sig=Nfd6l6SGUOhX5XrGQ48f7jjGGEzsnQykOidZtn9bpxg%3D","timestamp":"2022-05-18T20:39:51"}
# 
# {
# "content": "{upn:cloud-admin@example.com,url:https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-20h-30m-23s-3023ms?se=2022-05-18T21%3A08Z&sp=rl&sv=2021-04-10&sr=c&sig=Nfd6l6SGUOhX5XrGQ48f7jjGGEzsnQykOidZtn9bpxg%3D,timestamp:2022-05-18T20:39:51}",
# "dequeueCount": null,
# "expirationTime": "2022-05-19T20:39:54+00:00",
# "id": "00000000-0000-0000-0000-000000000000",
# "insertionTime": "2022-05-18T20:39:54+00:00",
# "popReceipt": "AgAAAAMAAAAAAAAAvkgjbvdq2AE=",
# "timeNextVisible": "2022-05-18T20:39:54+00:00"
# }
#########################################################################################################################################


#########################################################################################################################################
# OPTION 6 
# $message = "{""upn"":""$upnName"",""url"":""$BlobFileDownloadUrl"",""timestamp"":""$timestamp""}"
#$message = $message | ConvertTo-Json -compress ; $message = $message.Replace("\n","") ; $message = $message.Replace("\r","") ; $message = $message.Replace(" ","") ;
#########################################################################################################################################

""
""
""
Write-Host "Message Content with new format:"
$message
""
""
""

# VALID MESSAGES:
#$message = "{""upn"":""cloud-user@enterprisecom"",""timestamp"":""2022-05-18T18:45:09""}"
#$message = "{\""upn\"":\""cloud-admin@example.com\"",\""timestamp\"":\""2022-05-18T18:45:09\""}"
#$message = "{\""upn\"":\""cloud-admin@example.com\"",\""url\"":\""https://dev-appenterprisesa.blob.core.windows.net/co-integration-service-onprem-enterprise-dev-app/blob-integration-service-onprem-enterprise-dev-app-2022-05-18-18h-46m-55s-4655ms?se=2022-05-18T19%3A27Z&sp=rl&sv=2021-04-10&sr=c&sig=V%2B%2BzqLzrid6n2Ftzz/SuB68cdvJ05lBOfMk4A63q3JY%3D\"",\""timestamp\"":\""2022-05-18T18:59:15\""}"

write-host "az storage message put:"
az storage message put --content $message --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --time-to-live 86400 #--debug --verbose




