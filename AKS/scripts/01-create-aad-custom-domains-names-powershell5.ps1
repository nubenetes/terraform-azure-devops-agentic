# scripts/01-create-aad-custom-domains-names-powershell5.ps1

# DO NOT USE THIS SCRIPT, SINCE THE CODE INCLUDES DEPRECATED POWERSHELL MODULES !!

# DEPRECATED: https://github.com/uglide/azure-content/blob/master/articles/active-directory/active-directory-add-manage-domain-names.md

# https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0&preserve-view=true
# https://docs.microsoft.com/en-us/powershell/azure/active-directory/ad-pshell-v2-version-history?view=azureadps-2.0

# https://docs.microsoft.com/en-us/powershell/module/msonline/get-msoldomain?view=azureadps-1.0

# https://docs.microsoft.com/en-us/answers/products/graph

########################################################################################
# Azure AD module is ONLY supported on Windows operating systems with Poweshell 5.1 
# Azure AD module is NOT Powershell 7.x compliant
# Azure AD is DEPRECATED and replaced by Microsoft Graph Powershell SDK (aka Microsoft Graph)
########################################################################################

########################################################################################
# Two Azure Powershell modules are supported (NEW ONES, NO DEPRECATED):
#   - Az Module (based on Azure Resource Manager)
#   - Microsoft Graph (based on Microsoft Graph Powershell SDK)
########################################################################################

##################################################################################################################
# DEPRECATED!
# Azure Active Directory (MSOnline) aka MSOnline V1 Powershell 
# Replaced by Azure Active Directory V2 PowerShell module 
# https://docs.microsoft.com/en-us/powershell/module/msonline/
# https://docs.microsoft.com/en-us/powershell/azure/active-directory/overview
# 
# MSOnline is planned for deprecation. For more details on the deprecation plans, see the deprecation update. 
# You can start trying Microsoft Graph PowerShell to interact with Azure AD as you would in MSOnline. 
# In addition, Microsoft Graph PowerShell allows you access to all Microsoft Graph APIs and is available on PowerShell 7. 
# For answers to frequent migration queries, see the migration FAQ.
# 
###################################################################################################################

#########################################################################################################################################
# DEPRECATED!
# Azure Active Directory V2 PowerShell module - aka Azure Active Directory PowerShell for Graph (Azure Active Directory PowerShell 2.0)
# https://docs.microsoft.com/en-us/powershell/azure/active-directory/overview
# 
# Azure AD PowerShell is planned for deprecation. For more details on the deprecation plans, see the deprecation update. 
# You can start trying Microsoft Graph PowerShell to interact with Azure AD as you would in Azure AD PowerShell. 
# In addition, Microsoft Graph PowerShell allows you access to all Microsoft Graph APIs and is available on PowerShell 7. 
# For answers to frequent migration queries, see the migration FAQ.
# 
#########################################################################################################################################

#########################################################################################################################################
# HOW TO RUN THIS SCRIPT FROM AZURE DEVOPS TASK - MAKE SURE IT IS RUN WITH POWERSHELL 5.1 :
# jobs: 
# - job: createAADCustomDomainNames
#   dependsOn: DeployInfra
#   #condition: false
#   pool:
#     vmImage: 'windows-2022'
#     #vmImage: 'ubuntu-22.04'
#     #vmImage: 'macOS-12'
#   variables:  # https://docs.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs
#     list_of_aad_custom_domain_name: 
#   timeoutInMinutes: 15 # how long to run the job before automatically cancelling
#   cancelTimeoutInMinutes: 0 # how much time to give 'run always even if cancelled tasks' before stopping them
#   steps:
#     - bash: |
#         echo "List of AAD Custom Domain Names (LIST_OF_AAD_CUSTOM_DOMAIN_NAMES):" $(LIST_OF_AAD_CUSTOM_DOMAIN_NAMES)
#       displayName: show vars
#     - task: AzurePowerShell@5
#       displayName: 'run scripts/01-create-aad-custom-domains-names-powershell5.ps1'
#       inputs:
#         azureSubscription: $(SERVICE_CONNECTION_NAME)
#         scriptType: 'FilePath'
#         scriptPath: '$(System.DefaultWorkingDirectory)/scripts/01-create-aad-custom-domains-names-powershell5.ps1'  # https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables
#         scriptArguments:
#           -domainNameList $(LIST_OF_AAD_CUSTOM_DOMAIN_NAMES)
#         azurePowerShellVersion: 'latestVersion' # Required. Options: latestVersion, otherVersion
#         pwsh: false   # true = powershell 7.x , false = powershell 5.1 - Azure Active Directory version 2 cmdlets require powershell 5.1
#########################################################################################################################################

param($domainNameList)
Write-Host "This script will be run with the following parameters:"

Write-Host "domainNameList: $domainNameList" # List of AAD Domain Names 

#################
# Start of script
#################
Foreach ($domainName in $domainNameList)
{

    Write-Host "Working on domainName (AAD Custom Domain Name): $domainName"
    Write-Host "Check Powershell Version (5.1 required)"
    $PSVersionTable.PSVersion
    ""
    ""
    ""   

    # Write-Host "Get-PackageProvider"
    # Get-PackageProvider
       
    ##################################################################################################################################   
    # Azure AD Graph API - aka Azure Active Directory PowerShell for Graph (Deprecated, let's migrate to Microsoft Graph Powershell) 
    # https://docs.microsoft.com/en-us/powershell/azure/active-directory/ad-pshell-v2-version-history?view=azureadps-2.0      
    # Write-Host "Setup AzureAD module"
    # Install-Module -Force AzureAD
    # Write-Host "List AzureAD module"
    # Get-Module -ListAvailable -Name AzureAD | Format-List
    #
    # Write-Host "Setup AzureADPreview module"
    # Install-Module -Force AzureADPreview
    # Write-Host "List AzureADPreview module"
    # Get-Module -ListAvailable -Name AzureADPreview | Format-List    
    ##################################################################################################################################   
    

    ##################################################################################################################################   
    # Microsoft Graph PowerShell aka Microsoft Graph API
    # Azure AD PowerShell will continue to function after June 2022 to allow users more time to migrate to Microsoft Graph PowerShell.
    # https://docs.microsoft.com/en-us/powershell/azure/active-directory/migration-faq?view=azureadps-2.0
    # https://docs.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    ##################################################################################################################################   
    Write-Host "Get access token of Microsoft Graph endpoint for current account:"
    $accessToken = Get-AzAccessToken -ResourceTypeName MSGraph # Get access token of Microsoft Graph endpoint for current account
    #$accessToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/"  # A working alternative 
    ""
    ""
    ""
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
    Get-MgContext | Format-List
    ""
    ""
    ""
    Write-Host "Get-MgDomain: Get a list of domaim objects"
    #Get-MgDomain | Format-List    # Insufficient privileges to complete the operation
    ""
    ""
    ""    
    Write-Host "View My Scopes: (Get-MgContext).Scopes"
    (Get-MgContext).Scopes | Format-List
    ""
    ""
    ""
    
    Write-Host "Setup MSOnline module"
    Install-Module -Force MSOnline
    Write-Host "List MSOnline module"
    Get-Module -ListAvailable -Name MSOnline | Format-List
    ""
    ""
    ""
    Write-Host "List available modules"
    Get-Module -ListAvailable | Format-List
    ""
    ""
    ""   
    #Write-Host "Import MSOnline module"
    #Import-Module -Name MSOnline
    #Write-Host "Import all modules specified by the module path"
    #Get-Module -ListAvailable | Import-Module # Starting in PowerShell 3.0, installed modules are automatically imported to the session when you use any commands or providers in the module.
    
    Write-Host "Connect-MsolService"
    #$Msolcred = Get-credential 
    #Connect-MsolService -Credential $MsolCred
    Connect-MsolService -MsGraphAccessToken $accessToken.Token
    Write-Host "Powershell 5.1: Get all domains for the company"
    # https://docs.microsoft.com/en-us/powershell/module/msonline/get-msoldomain?view=azureadps-1.0
    Get-MsolDomain | Format-List
    #Write-Host "Powershell: Create an AAD Custom Domain Name"
    #New-MsolDomain -Name $domainName

    #"Waiting for the item to be fully provisioned..."
    #Start-Sleep -Seconds 30
}