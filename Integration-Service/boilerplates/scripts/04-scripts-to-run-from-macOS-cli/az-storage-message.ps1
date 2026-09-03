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
$message = "{""upn"":""$upnName"",""timestamp"":""$timestamp""}"
#$message = "{`"upn`":`"$upnName`",`"timestamp`":`"$timestamp`"}"

Write-Host "JSON Content:"
$message

$message = $message | ConvertTo-Json
""
""
""
Write-Host "JSON Content:"
$message
""
""
""
write-host "az storage message put:"
az storage message put --content $message --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --time-to-live 86400 #--debug --verbose
""
""
""
# write-host "az storage message get:"
# $result = az storage message get --queue-name $queueName --account-name $storageAccount --connection-string $storageAccountConnectionString --visibility-timeout 300  | ConvertFrom-Json #--debug --verbose
# write-host "result is:"
# $result
# write-host "result.content is:"
# $result.content







# JSON Content:
# {"upn":"cloud-admin@example.com","timestamp":"22-05-17 11:48:49"}
#
# JSON Content:
# "{\"upn\":\"cloud-admin@example.com\",\"timestamp\":\"22-05-17 11:48:49\"}"
#
# az storage message put:
# {
#   "content": "{\"upn\":\"cloud-admin@example.com\",\"timestamp\":\"22-05-17 11:48:49\"}",
#   "dequeueCount": null,
#   "expirationTime": "2022-05-18T09:48:50+00:00",
#   "id": "00000000-0000-0000-0000-000000000000",
#   "insertionTime": "2022-05-17T09:48:50+00:00",
#   "popReceipt": "AgAAAAMAAAAAAAAAexeaT9Np2AE=",
#   "timeNextVisible": "2022-05-17T09:48:50+00:00"
# }
#
# az storage message get:
# result is:
#
# content         : {"upn":"cloud-admin@example.com","timestamp":"22-05-17 11:48:49"}
# dequeueCount    : 1
# expirationTime  : 18/5/2022 11:48:50
# id              : 00000000-0000-0000-0000-000000000000
# insertionTime   : 17/5/2022 11:48:50
# popReceipt      : AgAAAAMAAAAAAAAA4KvDAtRp2AE=
# timeNextVisible : 17/5/2022 11:53:50
#
# result.content is:
# {"upn":"cloud-admin@example.com","timestamp":"22-05-17 11:48:49"}
