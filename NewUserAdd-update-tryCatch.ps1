# STEP 1: CREATE THE USER OBJECT:
    # Setting the varible of the user input outside of the object function keeps the values consistent.

    function FirstName {
        $firstName = Read-Host -Prompt "Enter the user first name"
        $trigger = $true

        do {
            if("" -ne $firstName){
                $trigger = $false
            }
            else {
                $firstName = Read-Host -Prompt "Must have a value for first name"
            }    
        }
    
        while ($trigger -eq $true)
    
        return $firstName
    }

    function LastName {
        $lastName = Read-Host -Prompt "Enter the user last name"
        $trigger = $true

        do {
            if("" -ne $lastName){
                $trigger = $false
            }
            else {
                $lastName = Read-Host -Prompt "Must have a value for last name"
            }    
        }
    
        while ($trigger -eq $true)
    
        return $lastName
    }

    function DisplayName {
        $displayName = Read-Host -Prompt "Enter the name in the way it should be displayed"
        $trigger = $true

        do {
            if("" -ne $displayName){
                $trigger = $false
            }
            else {
                $displayName = Read-Host -Prompt "Must have a value for display name spaces are fine"
            }    
        }
    
        while ($trigger -eq $true)
    
        return $displayName
    }

    function NameCheck {
        $accountName = Read-Host -Prompt "Enter a unique name"
    
        do {
            try {
                $nameCheck = Get-ADUser -Identity $accountName
               }
                    catch {
                        $nameCheck = $null
                    }
    
            $altNameCheck = Get-ADUser -Filter "EmailAddress -like '$accountName@*'"
    
            $trigger = $true
    
            if (($null -eq $nameCheck) -and ($null -eq $altNameCheck)) {
                $trigger = $false
            }
            else {
                $accountName = Read-Host -Prompt "This user exists enter a unique name"
            }
        }
        while ($trigger -eq $true)
    
        return $accountName
    }

    function PasswordValidate {
        
        $password = Read-Host -Prompt "Enter a Secure Password" -AsSecureString
        $trigger = $true
    
        do {
            if("" -ne $password){
                $trigger = $false
            }
            else {
                $password = Read-Host -Prompt "Must have an upper case and number at least" -AsSecureString
            }    
        }
    
        while ($trigger -eq $true)
    
    
        return $password
    }

    function UserManager {
        $supervisor = Read-Host -Prompt "Enter the user Supervisor"

        do {
            try {
                $supeCheck = Get-ADUser -Identity $supervisor    
            }
            catch {
                $supeCheck = $null
            }
            
            $trigger = $true

            if ($null -ne $supeCheck) {
                $trigger = $false
            }
            else {
                $supervisor = Read-Host -Prompt "Enter the user name of an exisitng user"
            }
        }
        while ($trigger -eq $true)

        return $supervisor 
    }

    function ChooseOffice {

        $office = Read-Host -Prompt "Enter A for Arkansas, C for Chicago, K for Kansas, O for Ohio"
    
        do {
    
            $propmtArray = @('a','c','k','o')
            $trigger = $true
    
            if ($propmtArray -contains $office) {
                switch ( $office ) {
                    'a' { $result = 'Company Arkansas'}
                    'c' { $result = 'Company Chicago'}
                    'k' { $result = 'Company Kansas'}
                    'o' { $result = 'Company Ohio'}
                }
    
                $trigger = $false
            }
            else {
                $office = Read-Host -Prompt "Enter a  letter from the selection"
            }        
        }
    
        while ($trigger -eq $true)
    
        return $result
    }

    function UserCopy {
        $adUserCopy = Read-Host -Prompt "Enter User to Copy to populate Group List"

        do {
            try {
                    $adUserCheck = Get-ADUser -Identity $adUserCopy        
                }
                catch {
                    $adUserCheck = $null
                }
            
            $trigger = $true

            if ($null -ne $adUserCheck) {
                $trigger = $false
            }
            else {
                $adUserCopy = Read-Host -Prompt "Enter the user name of an exisitng user"
            }
        }
        while ($trigger -eq $true)

        return $adUserCopy
    }

    function GroupList {
        @(Get-ADPrincipalGroupMembership -Identity $adUserCopy -ErrorAction 'silentlycontinue' | Where-Object distinguishedName -ne "CN=Domain Users,CN=Users,DC=CompanyDomain,DC=local")     
    }

    $firstName = FirstName
    $lastName = LastName
    $displayName = DisplayName
    $accountName = NameCheck
    $fullName = $firstName + " " + $lastName
    $title = Read-Host -Prompt "Enter the user Title"
    $supervisor = UserManager
    $password = PasswordValidate
    $email = "$accountName@company.com"
    $userPrincipalName = "$accountName@company.com"
    $directory = "\\FileServer\users\$accountName"
    $office = ChooseOffice
    $description = Read-Host -Prompt "Enter the user Job Description"
    $homeDrive = "H:"
    $company = "Company Name"
    $department = Read-Host -Prompt "Enter the user Department"
    $proxyAddress = "SMTP:$accountName@company.com"
    $adUserCopy = UserCopy
    $groupList = GroupList
    $path = "OU=Company USERS,DC=CompanyDomain,DC=local"
    $enabled = $true

# Creates the object

    $newADUser = @{
        GivenName = $firstName
        Surname = $lastName
        DisplayName = $displayName
        Name = $fullName
        SamAccountName = $accountName
        Title = $title
        Manager = Get-ADuser -Identity $supervisor -Properties *| select-object -ExpandProperty distinguishedName
        AccountPassword = $password
        EmailAddress = $email
        UserPrincipalName = $userPrincipalName
        HomeDirectory = $directory
        Office= $office
        Description = $description
        HomeDrive = $homeDrive
        Company = $company
        Department = $department
        Path = $path
        Enabled = $enabled
    }
# Pause to look over the results and option to continue

    $newADUser
    function PauseThenPush {
        $whereWeGoin = Read-Host -Prompt "If this is correct enter type YES to continue"
        if ($whereWeGoin -eq 'yes') {

            Write-Host "Entering User into AD"

            New-ADUser @newADUser
        }
        else {
            Write-Host "Closing script"
        }
    }
    Function AddGroups {
        foreach ($group in $groupList) {
            try
            {
                Add-ADGroupMember -Identity $group.distinguishedName -Members $newADUser.SamAccountName -Confirm:$false -ErrorAction Stop -Verbose
            }
            catch
            {
                Write-Host "Error while adding user to adgroup"
            }
        }
    }

    function AddProxy {
        $userCheck = Get-ADUser -Identity $newADUser.SamAccountName
        if ($null -ne $userCheck) {
            Set-ADUser -Identity $newADUser.SamAccountName -add @{ProxyAddresses = $proxyAddress}
            return $newADUser.ProxyAddresses
        }
        else {
            Write-Host "User is not in AD"
        }
    }

    PauseThenPush
    AddGroups
    AddProxy