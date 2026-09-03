# scripts/01-assign-customSecurityAttributes.ps1
# https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/users-custom-security-attributes
# https://learn.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0-preview
# https://www.delftstack.com/howto/powershell/pass-an-argument-to-a-powershell-script/
# https://learn.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-7.3
# https://learn.microsoft.com/en-us/powershell/gallery/overview?view=powershellget-2.x
# https://github.com/actions/runner-images/blob/main/images/win/Windows2022-Readme.md
# https://learn.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershellget-2.x
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command?view=powershell-7.3
# https://learn.microsoft.com/en-us/powershell/module/azuread/get-azureaduser?view=azureadps-2.0-preview

# The Azure AD PowerShell for Graph module has two versions: a Public preview version and a General Availability version.
# It is not recommended to use the Public Preview version for production scenarios.
# The Azure AD PowerShell for Graph preview module can be downloaded from the PowerShell Gallery at the AzureADPreview page: https://www.powershellgallery.com/packages/AzureADPreview
# The Azure AD PowerShell for Graph General Availability module can be downloaded from the PowerShell Gallery at the AzureAD page.

#######################################################################################################################################################
# Non-working solution even though is the one documented at learn.microsoft.com: Azure AD PowerShell is about to be deprecated
#######################################################################################################################################################

param($userList)
$userList = $userList | ConvertFrom-Json
Write-Host "userList after ConvertFrom-Json: $userList"
Write-Host "Check Powershell Version:"
$PSVersionTable.PSVersion
#################
# Start of script
#################
Write-Host "Get access token of Microsoft Graph endpoint for current account"
$accessToken = Get-AzAccessToken -ResourceTypeName MSGraph # Get access token of Microsoft Graph endpoint for current account
$accessToken

#Write-Host "Install-Module Microsoft.Graph"
#Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck

Write-Host "Connect-MgGraph -AccessToken"
Connect-MgGraph -AccessToken $accessToken.Token
Write-Host "Select MgProfile Beta"
Write-Host "Without MgProfile Beta new cmdlets like New-MgDirectoryAttributeSet are NOT recognized"
Select-MgProfile -Name "beta"

#######################################################################################################################################################
# Azure AD PowerShell is about to be deprecated
Write-Host "Install-module AzureADPreview"
Install-module -Name AzureADPreview -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
Write-Host "Import-Module AzureADPreview"
Import-Module -Name AzureADPreview

Write-Host "Connect-AzureAD"
Connect-AzureAD -AadAccessToken $accessToken.Token -AccountId $accessToken.UserId -TenantId $accessToken.TenantId #-AzureEnvironmentName AzureCloud
#Connect-AzureAD -MsAccessToken $accessToken.Token -AccountId $accessToken.UserId -TenantId $accessToken.TenantId #-AzureEnvironmentName AzureCloud
#######################################################################################################################################################

Write-Host "Assign Custom Security Attribute per user with Set-AzureADMSUser"
Foreach ($user in $userList) {
    #$user
    Write-Host "==========================="
    $user.email

    $centerName = $user.center
    $upName = $user.upn

    Write-Host "Working on centerName (AETitle): $centerName"
    Write-Host "Working on upName (test user - user principal): $upName"
    $attributesUpdate = @{
        EnterpriseCore = @{
            "@odata.type"        = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
            "cloud-admin@example.com" = "#Collection(String)"
            AETitle              = @($centerName)
        }
    }
    #Set-PSDebug -Trace 2;
    Write-Host "Get-AzADUser"
    # $azAdUser = Get-AzADUser -Filter "userPrincipalName eq '$upName'"
    # $azAdUser
    # write-Host "User ObjectID is:"
    # $azAdUser.Id

    $upObj = Get-MgUser -Filter "UserPrincipalName eq '$upName'"
    $upObj

    Write-Host "Set-AzureADMSUser"
    Set-AzureADMSUser -Id $upObj.Id -CustomSecurityAttributes $attributesUpdate
    # Azure AD PowerShell is about to be deprecated. Current Error:
    ##[error]Object reference not set to an instance of an object.

    # Update-AzADUser (custom security attribute not available)
    # Update-MgUser  (custom security attribute not available)
}
