#!/bin/bash
# https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-integrate-app-service-with-application-gateway

# Integrate App Service with Application Gateway
# set -e # exit if error
# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="northeurope"
resourceGroup="rg-appcore-myclient-dev-$randomIdentifier"
tag="integrate-with-app-gateway"
vNet="msdocs-app-service-vnet-$randomIdentifier"
subnet="msdocs-app-service-subnet-$randomIdentifier"
appServicePlan="msdocs-app-service-plan-$randomIdentifier"
webapp="msdocs-web-app-$randomIdentifier"
appcore_agw="msdocs-app-gateway-$randomIdentifier"
publicIpAddress="msdocs-public-ip-$randomIdentifier"



# Create a resource group.
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create network resources
az network vnet create --resource-group $resourceGroup --name $vNet --location "$location" --address-prefix 127.0.0.1/16 --subnet-name $subnet --subnet-prefix 127.0.0.1/24

az network public-ip create --resource-group $resourceGroup --location "$location" --name $publicIpAddress --dns-name $webapp --sku Standard --zone 1

# Create an App Service plan in `S1` tier
echo "Creating $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku S1

# Create a web app.
echo "Creating $webapp"
az webapp create --name $webapp --resource-group $resourceGroup --plan $appServicePlan

appFqdn=$(az webapp show --name $webapp --resource-group $resourceGroup --query defaultHostName -o tsv)

# Create an Application Gateway
az network application-gateway create --resource-group $resourceGroup --name $appcore_agw --location "$location" --vnet-name $vNet --subnet $subnet --min-capacity 2 --sku Standard_v2 --http-settings-cookie-based-affinity Disabled --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http --public-ip-address $publicIpAddress --servers $appFqdn

az network application-gateway http-settings update --resource-group $resourceGroup --gateway-name $appcore_agw --nameappcore_agwBackendHttpSettings --host-name-from-backend-pool

# Apply Access Restriction to Web App
az webapp config access-restriction add --resource-group $resourceGroup --name $webapp --priority 200 --rule-name gateway-access --subnet $subnet --vnet-name $vNet

# Get the App Gateway Fqdn
az network public-ip show --resource-group $resourceGroup --name $publicIpAddress --query {appcore_agwFqdn:dnsSettings.fqdn} --output table


