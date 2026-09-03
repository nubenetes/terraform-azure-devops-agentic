# scripts/01-assign-customSecurityAttributes.ps1

# https://www.delftstack.com/howto/powershell/pass-an-argument-to-a-powershell-script/

###################################################
# Input parameters with Terraform Format:
#
# The first two ones are lists _but_ with terraform data type. They need to be translated into powershell format:
#
# upNameList: ["testuser1","testadmin"]
# centerNameList: ["client-anon","client2"]
# envName: dev
###################################################

param($upNameList, $centerNameList, $envName = "dev", $locationCode = "ne", $gitBranch = "")
Write-Host "This script will be run with the following parameters:"

##################################################################################
# Convert terraform list format into powershell list format:
$upNameList = $upNameList.replace('[','')
$upNameList = $upNameList.replace(']','')
$upNameList = $upNameList.replace('"','')
$upNameList = $upNameList.Split(",")
$centerNameList = $centerNameList.replace('[','')
$centerNameList = $centerNameList.replace(']','')
$centerNameList = $centerNameList.replace('"','')
$centerNameList = $centerNameList.Split(",")
##################################################################################

Write-Host "upNameList: $upNameList"            # List of Users (User Principals / Security Principals)
Write-Host "centerNameList: $centerNameList"    # List of AETitle(s)
Write-Host "envName: $envName"
Write-Host "locationCode: $locationCode"
Write-Host "gitBranch: $gitBranch"
""
""
""
Write-Host "Check Powershell Version:"
$PSVersionTable.PSVersion
""
""
""
#################
# Start of script
#################
Foreach ($centerName in $centerNameList)
{
    Write-Host "Working on centerName (AETitle): $centerName"
    ""
    ""
    ""
    Foreach ($upName in $upNameList)
    {
        Write-Host "Working on upName (test user - user principal): $upName"
        ""
        ""
        ""
        $upName = "$upName-appcore-$centerName-${gitBranch}${locationCode}$cloud-admin@example.com"  # UPN , defined in terraform resource "azuread_user" "testuser1"
        $upName
        ""
        ""
        ""
        Write-Host "Get access token of Microsoft Graph endpoint for current account:"
        $accessToken = Get-AzAccessToken -ResourceTypeName MSGraph # Get access token of Microsoft Graph endpoint for current account
        #$accessToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/"  # A working alternative
        ""
        ""
        ""
        #####################################################################
        # Connect-MgGraph
        # The SDK supports two types of authentication: delegated access and app-only access.
        # App-only access via Client Credential with a certificate.
        #
        # https://github.com/microsoftgraph/msgraph-sdk-powershell
        #####################################################################
        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring
        Write-Host "ConvertTo-SecureString -AsPlainText"
        $token = ConvertTo-SecureString -AsPlainText $accessToken.Token  # convert the value of type System.String to type System.Security.SecureString
        Write-Host "Connect-MgGraph -AccessToken"
        Connect-MgGraph -AccessToken $token
        ""
        ""
        ""
        #######################################################################################################################################################################
        # Connect-MgGraphAz (Microsoft Graph Extension): An alternative to "Connect-MgGraph -AccessToken" (finally not necessary):
        #
        # [FEATURE REQUEST] Add Connect-Graph -AzContext Option : https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/509
        # https://www.powershellgallery.com/packages/JustinGrote.Microsoft.Graph.Extensions/
        # https://github.com/JustinGrote/JustinGrote.Microsoft.Graph.Extensions/blob/main/src/Public/Connect-MgGraphAz.ps1
        # Write-Host "Install Graph Extension: JustinGrote.Microsoft.Graph.Extensions" #https://www.powershellgallery.com/packages/JustinGrote.Microsoft.Graph.Extensions/
        # Install-Module -Name JustinGrote.Microsoft.Graph.Extensions -Force -AllowClobber

        # Write-Host "Get-Command -Module JustinGrote.Microsoft.Graph.Extensions"
        # Get-Command -Module JustinGrote.Microsoft.Graph.Extensions

        # # CommandType     Name                                               Version    Source
        # # -----------     ----                                               -------    ------
        # # Function        Connect-MgGraphAz                                  0.0.2      JustinGrote.Microsoft.Graph.Extensions
        # # Function        Disable-MgEventualConsistencyDefault               0.0.2      JustinGrote.Microsoft.Graph.Extensions
        # # Function        Get-MgAppRole                                      0.0.2      JustinGrote.Microsoft.Graph.Extensions
        # # Function        Get-MgManagedIdentity                              0.0.2      JustinGrote.Microsoft.Graph.Extensions
        # # Function        Get-MgO365ServicePrincipal                         0.0.2      JustinGrote.Microsoft.Graph.Extensions

        # Write-Host "Connect-MgGraphAz"
        # Get-AzContext | Connect-MgGraphAz
        #######################################################################################################################################################################

        ###########################################################################################################################################################
        # No longer required since July 2023: https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/2104 Select-MgProfile cmdlet missing in 2.0.0-rc3
        # By default, the SDK uses the Microsoft Graph REST API v1.0. You can change this by using the Select-MgProfile command.
        # Write-Host "Select MgProfile Beta"
        # Write-Host "Without MgProfile Beta new cmdlets like New-MgDirectoryAttributeSet are NOT recognized"
        # Select-MgProfile -Name "beta"
        ###########################################################################################################################################################
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
        Write-Host "Powershell: Assign a custom security attribute with a string value to a User Principal:"
        # https://docs.microsoft.com/en-us/graph/api/serviceprincipal-update?view=graph-rest-beta&tabs=powershell
        #   To assign custom security attributes, the calling principal must be assigned the
        #   Attribute Assignment Administrator role and must be granted the CustomSecAttributeAssignment.ReadWrite.All permission.

        # Howto call a REST API:
        # https://github.com/johnthebrit/RandomStuff/blob/master/FunctionResGraphPowerShell/CallRestAPI.ps1
        ""
        ""
        ""
        Write-Host "Get User Principal Object ID:"
        ""
        ""
        ""
        $upObj = Get-MgUser -Filter "UserPrincipalName eq '$upName'"
        $upObj
        ""
        ""
        ""
        #Simple Test Harness to call a rest API
        $URIValue = "https://graph.microsoft.com/beta/users/$($upObj.Id)"

        # Write-Host "Get Access Token:"
        $authHeader = @{
            'Content-Type'='application/json'
            'Authorization'='Bearer ' + $accessToken.Token
        }
        Write-Host "Invoke-RestMethod GET"
        $resp = Invoke-RestMethod -Uri $URIValue -Method GET -Headers $authHeader
        $resp
        ""
        ""
        ""

        #####################################################################################################################################
        # $centerName should NOT CONTAIN special symbols such as <>\'& -> Automatic character escape feature of ConvertTo-Json
        # ConverTo-Json is removed from scripts like 11-storageMessage-END-URL.ps1 to avoid this issue.
        # We have no problems so far with the below solution in this script:
        #####################################################################################################################################

        # Pretty json in powershell with arrays and ConverTo-Json:
        $BodyJSON = @{
            "customSecurityAttributes" = @{
                    "EnterpriseCore" = @{
                        "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
                        "AETitle" = "$centerName"
                    }
                }
        } | ConvertTo-Json


        write-host "URIValue:"
        $URIValue
        ""
        ""
        ""
        Write-Host "authHeader"
        $authHeader
        ""
        ""
        ""
        Write-Host "BodyJSON:"
        $BodyJSON
        ""
        ""
        ""
        Write-Host "Invoke-RestMethod PATCH"
        $response = Invoke-RestMethod -Uri $URIValue -Method Patch -Headers $authHeader -Body $BodyJSON -ContentType 'application/json'
            # or use Invoke-WebRequest (RestMethod automatically parses returned JSON in content but less overall info)
        $content = $response.Status
        Write-Host "content:"
        $content
        ""
        ""
        ""
        "Waiting for the assignment to be fully provisioned..."
        Start-Sleep -Seconds 30

    }

}