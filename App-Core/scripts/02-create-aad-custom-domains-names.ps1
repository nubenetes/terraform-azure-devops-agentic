# scripts/02-create-aad-custom-domains-names.ps1

# DEPRECATED: https://github.com/uglide/azure-content/blob/master/articles/active-directory/active-directory-add-manage-domain-names.md

# https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0&preserve-view=true
# https://docs.microsoft.com/en-us/powershell/azure/active-directory/ad-pshell-v2-version-history?view=azureadps-2.0

param($domainNameList)
Write-Host "This script will be run with the following parameters:"

Write-Host "domainNameList: $domainNameList" # List of AAD Domain Names 

#################
# Start of script
#################
Foreach ($domainName in $domainNameList)
{

    Write-Host "Working on domainName (AAD Custom Domain Name): $domainName"


    Write-Host "Connect-MgGraph -AccessToken"
    Connect-MgGraph -AccessToken $accessToken.Token
    ""
    ""
    ""
    Write-Host "Select MgProfile Beta"
    Write-Host "Without MgProfile Beta new cmdlets like New-MgDirectoryAttributeSet are NOT recognized"
    Select-MgProfile -Name "beta"
    ""
    ""
    ""
    Write-Host "Get-MgContext"
    #View my scope
    Get-MgContext
    ""
    ""
    ""
    Write-Host "View My Scopes: (Get-MgContext).Scopes"
    (Get-MgContext).Scopes
    ""
    ""
    ""
    Write-Host "Powershell: Create an AAD Custom Domain Name"
    New-MsolDomain -Name $domainName

    "Waiting for the item to be fully provisioned..."
    Start-Sleep -Seconds 30
}