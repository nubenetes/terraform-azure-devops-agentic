
Write-Host "This script will be run with the following parameters defined in a DevOps Azure Pipeline YAML file:"
$centerName=$args[0]
write-host $centerName
$environment=$args[1]
write-host $environment

#################
# Start of script
#################
""
""
""
$keyVaultName = 'kv-'+$centerName+'-'+$environment    # kv-enterprise-dev-app     
$storageAccountNameInKeyVault = $centerName+'-sa'
$storageAccountAccessKeyInKeyVault = $centerName+'-mkey'

Write-Host "Get Keys from Key Vault:"
az keyvault secret show --name $storageAccountAccessKeyInKeyVault --vault-name $keyVaultName
""
""
""
$sa = az keyvault secret show --name $storageAccountNameInKeyVault --vault-name $keyVaultName | ConvertFrom-Json
$storageAccount = $sa.value
""
""
""
write-host "Storage Account Name retrieved from KeyVault:"
$storageAccount
""
""
""
#$saAccessKey = az keyvault secret show --name $storageAccountAccessKeyInKeyVault --vault-name $keyVaultName | ConvertFrom-Json
#$saSecret.value  

Write-Host "setup gobal variable needed by the next task: storageAccount"
Write-Host "##vso[task.setvariable variable=storageAccount]$storageAccount"
Write-Host "setup output variable needed by other stages: storageAccountOutput"
Write-Host "##vso[task.setvariable variable=storageAccountOutput;isOutput=true]$storageAccount"

