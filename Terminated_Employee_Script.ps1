# Updated:
# In order to remove pipe error on the Group Membership, I converted the pipe to a foreach on the DistinguishedName.

# Spelling errors fixed

$Title = "Delete Single or Multiple AD User Profiles"
$host.UI.RawUI.WindowTitle = $Title

#The script can take multiple values but there is no validaion so the name has to be correct. Also, there is no stop gap as of now so be careful.

#Global Variables:
$adUserArray = Read-Host -Prompt "Enter the users separated by comma"
$listofusers = @($adUserArray) -split ","

function DeleteUser {
# Establishing Variables:
    $targetOU = "OU=Shared Mailboxes,OU=Company USERS,DC=CompanyDomain,DC=local"
    # $testTargetOU = "OU=Company USERS,DC=CompanyDomain,DC=local"
    $telephoneAttributes = @('HomePhone','Pager','Mobile','facsimileTelephoneNumber','ipPhone')

    foreach($adUser in $listofusers) {
    # These are the commands that complete the Terminated user checklist in AD:

        # Change Password:
        Set-ADAccountPassword -Identity $adUser -NewPassword (ConvertTo-SecureString -AsPlainText "d!s@b13dP@55w)rt3" -Force)

        # Set Hidden Mailbox Status to True:
        Get-ADuser -Identity $adUser -property * | Set-ADObject -Replace @{msExchHideFromAddressLists=$true}

        # Set Manager to Null:
        Set-ADUSer $adUser -Manager $null

        # Set Department to Null
        Set-ADUSer $adUser -Department $null

        # Clear Phone Settings:
        Set-ADUser -Identity $adUser -Clear $telephoneAttributes

        # Move User to the Shared Mailbox Folder:
        Get-AdUser -Identity $adUser | Move-ADObject -TargetPath $TargetOU

        # Remove User from All Groups Except Domain Users:
        $groupMembership = @(Get-ADPrincipalGroupMembership -Identity $adUser | Where-Object Name -NotLike "Domain Users")
    
        foreach($group in $groupMembership) {
            Remove-ADGroupMember -Identity $group.distinguishedName -Members $adUser -Confirm:$false
        }
        
        # Disable Account:
        Disable-ADAccount -Identity $adUser
    }
}

Function UserReport {
    foreach($adUser in $listofusers) {
    # These are the commands to generate a Report

        $table = New-Object system.Data.DataTable "Deleted User Report"

        $name = Get-ADUser $adUser -Properties *
        $adUserName = $name.name

        $status = Get-ADUser $adUser | Select-Object SamAccountName, Enabled -ExpandProperty Enabled
        $manager = Get-ADUser $adUser -Properties * | Select-Object -ExpandProperty manager
        $department = Get-ADUser $adUser -Properties * | Select-Object -ExpandProperty Department

        $phone = Get-ADUser $adUser -Properties * | Select-Object HomePhone, Pager, Mobile, facsimileTelephoneNumber, ipPhone
        $phoneHome = $phone.HomePhone
        $phonePager = $phone.Pager
        $phoneMobile = $phone.Mobile
        $phonefax = $phone.facsimileTelephoneNumber
        $phoneIP = $phone.ipPhone
        $phoneItems = @("Home:       $phoneHome","Pager:        $phonePager","Mobile:      $phoneMobile","Fax:            $phonefax","IP Phone:   $phoneIP")

        $ouPath = Get-ADUser -Identity $adUser -Properties * | Select-Object -ExpandProperty DistinguishedName 
        $mailStatus = Get-ADuser -Identity $adUser -property * | Select-Object msExchHideFromAddressLists, Enabled -ExpandProperty Enabled
        $groupMember = Get-ADPrincipalGroupMembership -Identity $adUser | Select-Object  -ExpandProperty Name

        $col1 = New-Object system.Data.DataColumn Status_Enabled ,([string])
        $col2 = New-Object system.Data.DataColumn Manager,([string])
        $col3 = New-Object system.Data.DataColumn Department,([string])
        $col4 = New-Object system.Data.DataColumn Phone,([string])
        $col5 = New-Object system.Data.DataColumn OU_Path,([string])
        $col6 = New-Object system.Data.DataColumn Mailbox_View_Enabled,([string])
        $col7= New-Object system.Data.DataColumn Group_Membership,([string])

        $table.columns.add($col1)
        $table.columns.add($col2)
        $table.columns.add($col3)
        $table.columns.add($col4)
        $table.columns.add($col5)
        $table.columns.add($col6)
        $table.columns.add($col7)

        $row = $table.NewRow()

        $row.Status_Enabled = $status | Out-String
        $row.Manager = $manager | Out-String
        $row.Department = $department | Out-String

        $row.Phone = $phoneItems | Out-String

        $row.OU_Path = $ouPath | Out-String
        $row.Mailbox_View_Enabled = $mailStatus | Out-String
        $row.Group_Membership = $groupMember | Out-String

        $table.Rows.Add($row)
        $table | Out-GridView -Title "$adUserName Deleted User Report"
    }
}

#Hold for entry press. Pause for the script to take effect:
function ReportPause {
    param (
        [string]
        $message = 'Press Enter for a Report',

        [ConsoleKey]
        $key = [ConsoleKey]::Enter
    )
    
    # Write message:
    Write-Host -Object $message -ForegroundColor Yellow -BackgroundColor Black
    
    # use a blocking call because we *want* to wait
    do {
        $keyRead = [Console]::ReadKey($false)
    }
    until (
        $keyRead.Key -eq $key
    )
}

#Confirmation to run AD sync:
# function SyncNow {
#     param (
#         [string]
#         $message = "Would you like to sync now? Enter for Yes, ESC for No",

#         [ConsoleKey]
#         $keyYes = [ConsoleKey]::Enter,

#         [ConsoleKey]
#         $keyNo = [ConsoleKey]::Escape
#     )

#     Write-Host -Object $message -ForegroundColor Yellow -BackgroundColor Black

#     do {
#         $keyRead = [Console]::ReadKey($false)

#         if ($keyRead.Key -eq $keyYes) {
#             \\access\C$\Users\admin\Desktop\Full AD Sync with Azure.ps1
#         } 
#         elseif ($keyRead.Key -eq $keyNo) {
#             Exit
#         }
#     }
#     until ($keyRead.Key -eq $keyYes -OR $keyRead.Key -eq $keyNo) {  
#     }
# }

DeleteUser
ReportPause 
UserReport
# SyncNow -WhatIf

