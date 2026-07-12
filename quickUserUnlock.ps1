$adUser = ""
# $adUserArray = Read-Host -Prompt @("","","")

#Unlock Account:
    #Unlock-ADAccount -Identity $adUser
    # Get-ADUser $adUser -Properties * | Select-Object LockedOut
    
    # $groupMembership = @(Get-ADPrincipalGroupMembership -Identity $adUser | Where-Object Name -NotLike "Domain Users")

    # $groupMembership

    # foreach($group in $groupMembership) {
    #     Remove-ADGroupMember -Identity $group.distinguishedName -Members $adUser -Confirm:$false -WhatIf
    # } 
    
    
    Get-ADuser -Identity $adUser -property * | Select-Object msExchHideFromAddressLists, Enabled


    # Set-ADObject -Replace @{msExchHideFromAddressLists=$true}
    
    # | Remove-ADGroupMember -Members $adUser -Confirm:$false
#Change Password:

#Get User Properties
    # Get-ADUser $adUser -Properties *

    # foreach ($user in $adUserArray) {
    #     Get-ADUser $user -Properties *
    # }


#Make manager null
    #Set-ADUSer  -Manager $null
 