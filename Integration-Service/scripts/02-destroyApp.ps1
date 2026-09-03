####################################################################################################################
# Variables can be defined here or within the YAML based declarative pipeline (calling this script with parameters)
####################################################################################################################

Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$appName=$args[0]
write-host $appName

#################
# Start of script
#################


# Delete existing registered app and its service principal
Write-Host "Grab existing registered app and its service principal"
$existingRegisteredAppId = az ad app list --display-name $appName --query "[0].appId" -o tsv
$existingRegisteredAppId

if ($existingRegisteredAppId) {
	Write-Host "Delete existing registered app Id"
	az ad app delete --id $existingRegisteredAppId
	Write-Host "Waiting for the registered app to be removed..." 
	Start-Sleep -s 10

}
