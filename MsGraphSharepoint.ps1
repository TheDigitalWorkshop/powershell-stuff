# Boilerplate install and import of Modules:
# Install-Module Microsoft.Graph
# Import-Module Microsoft.Graph.Users

# Install-Module AzureAD
# Import-Module AzureAD

# Install-Module PnP.powershell
# Get-Command -Module PnP.powershell
# Import-Module PnP.powershell

# WARNING:
# You are running the legacy version of PnP PowerShell.

# This version will be archived soon which means that while staying available, no updates or fixes will be released.
# Consider installing the newer prereleased cross-platform version of PnP PowerShell.
# This version has numerous improvements and many more cmdlets available.
# To install the new version:

# Uninstall-Module -Name SharePointPnPPowerShellOnline -AllVersions -Force
# Install-Module -Name PnP.PowerShell

# Connect Commands:

# Connect-AzureAD
# Connect-MgGraph -Scopes "User.ReadWrite.All"

# Register-PnPManagementShellAccess

# $CompanyUrl = "https://company-admin.sharepoint.com/"
# Connect-SPOService -Url $CompanyUrl

# function Update-UserAttribute {
#     param (
#         [string]$UserId,
#         [string]$AttributeName,
#         [string]$AttributeValue
#     )

#     $params = @{
#         AdditionalProperties = @{
#             $AttributeName = $AttributeValue
#         }
#     }

#     Update-MgUser -UserId $UserId -BodyParameter $params
# }

# $AZuser = Get-MgUser -UserId "" -Property *
$ADuser = Get-ADUser -Identity "" -Properties *

# $AdUser
$ADuserMobile = $ADuser.MobilePhone
$ADuserFax = $ADuser.facsimileTelephoneNumber

# $users = Get-MgUser -All

# foreach ($user in $users) {
#     $newAttributeValue = "Your new value here"
#     Update-UserAttribute -UserId $user.Id -AttributeName "YourAttributeName" -AttributeValue $newAttributeValue
# }

#     $AZuser | Select-Object * | Out-GridView
#     $ADuser | Select-Object * | Out-GridView

#    $AZFaxProp = "FaxNumber"
#    $ADFaxProp = "facsimileTelephoneNumber"

#    $AZMobilePhone = "MobilePhone"
#    $ADMobilePhone = "MobilePhone"

#    $ADHomePhone = "HomePhone"

#    Import-Module AzureAD

# Automation Variables
$tenantName = ""
$spoAdminUrl = "https://$tenantName-admin.sharepoint.com"

# Try {
# Connect to AzureAD

# $AzureADUser = Get-AzureADUser -ObjectId ""

# $AzureADUser

# Connect to SPO using PnP
# $spoPnPConnection = Connect-PnPOnline -Url $spoAdminUrl -UseWebLogin

# Username removed after the |membership| > |memebership|user@company.com
Set-PnPUserProfileProperty -Account "i:0#.f|membership|" -PropertyName "CellPhone" -Value $ADuserMobile
Set-PnPUserProfileProperty -Account "i:0#.f|membership|" -PropertyName "Fax" -Value $ADuserFax




# Get all AzureAD Users with a populated MobilePhone property
#     $AzureADUsers = Get-AzureADUser -All $true | Where-Object {(![string]::IsNullOrWhiteSpace($_.Mobile))}

#     ForEach ($AzureADUser in $AzureADUsers) {
#         # Check to see if SPO UserProfileProperty CellPhone is null or empty
# 		if([string]::IsNullOrEmpty((Get-PnPUserProfileProperty -Account $AzureADUser.UserPrincipalName).UserProfileProperties.CellPhone)){
# 			Write-Output "Update CellPhone for $($AzureADUser.UserPrincipalName)"
# 			Set-PnPUserProfileProperty -Account $AzureADUser.UserPrincipalName -PropertyName CellPhone -Value $AzureADUser.Mobile
# 		}
# 		else{
# 			# Not going to overwrite existing property value
# 			Write-Output "Target SPO UPA CellPhone is not empty for $($AzureADUser.UserPrincipalName) and we're to preserve existing properties"
# 		}
#     }
# }
# Catch {
#     $exception = $_.Exception.Message
#     Write-Output "$($exception)"
# }