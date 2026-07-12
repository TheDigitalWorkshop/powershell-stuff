# Connect-ExchangeOnline -UserPrincipalName admin_user@company.com
Function RunCheck {
    #OU Path search variables
    $OUPaths = @( "OU=Corp,OU=BR1,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Executive,OU=BR1,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR1,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR2,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR5,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR6,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR7,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR8,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR10,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR11,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR12,OU=Standard Company Users,DC=Company,DC=local",
        "OU=Users,OU=BR13,OU=Standard Company Users,DC=Company,DC=local"
    )

    # Empty array to store results from each OU:
    $allUsers = @()
    foreach ($OUPath in $OUPaths) {

        # Get users from the current OU:
        $users = Get-ADUser -Filter * -Properties Enabled -SearchBase $OUPath | Where-Object { $_.Enabled -eq $True }

        # Add users from this OU to the main list:
        $allUsers += $users
    }

# Place users in readable list filter return properties:
$userList = $allUsers | Select-Object Name, UserPrincipalName

# Table View:
$userList | Format-Table -AutoSize

# Alternatively, export the lis

    # $userUpn = "Steve Kish"

    # # Define distribution list name (replace with actual name)
    $distributionListName = "All - Company"

    #Get a list of users and properties due to the fact that the user names can have hashes not names:
    $allCompanyMailUsers = Get-DistributionGroupMember -Identity $distributionListName | Select-Object *

    #Make it readable
    $allCompanyMailUsers | Select-Object Id, Alias, DisplayName

    # if ($response.StatusCode -eq 200) {
    #     Write-Host "User $userUpn is a member of the distribution list '$distributionListName'."
    # } else {
    #     Write-Host "User $userUpn is not a member of the distribution list '$distributionListName'."
    # }
}

Function AddUser {
    # Define variables
    $userPrincipalName = "user@company.com"
    $distributionListName = "All - Company"

    # Add user to distribution list
    Add-DistributionGroupMember -Identity $distributionListName -Member $userPrincipalName

    # Confirmation message
    Write-Host "User $userPrincipalName added to distribution list '$distributionListName'."
}

Function RemoveUser {
    # Define variables (same as adding)
    $userPrincipalName = "user@company.com"
    $distributionListName = "All - Company"

    # Remove user from distribution list
    Remove-DistributionGroupMember -Identity $distributionListName -Member $userPrincipalName

    # Confirmation message
    Write-Host "User $userPrincipalName removed from distribution list '$distributionListName'."
}

AddUser


# The hashes for the names are the way Microsoft is syncing users now:
# https://techcommunity.microsoft.com/t5/exchange-team-blog/change-in-naming-convention-of-user-s-name-parameter/ba-p/3284733