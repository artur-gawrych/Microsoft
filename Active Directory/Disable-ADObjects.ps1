$LogFilePath = "C:\Temp\Logs\InactiveAccounts.log"
if (!(Test-Path -Path $LogFilePath)) { New-Item -ItemType File -Path $LogFilePath -Force }

function Write-Log {
    param([string]$Message)
    $LogTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$LogTimestamp - $Message"
    Write-Output $LogMessage
    Add-Content -Path $LogFilePath -Value $LogMessage
}

$TimeStamp = (Get-Date).AddMonths(-3)

Write-Log "Processing inactive users and computers since $TimeStamp"

$ExcludedUsers = @() # Add any user account exceptions here
$ExcludedComputers = @() # Add any computer name exceptions here

$InactiveUsers = @(Get-ADUser -Filter * -Properties LastLogonDate, Enabled | 
    Where-Object { 
        ($_.Enabled -eq $True) -and 
        ($_.LastLogonDate -lt $TimeStamp) -and 
        ($_.LastLogonDate -ne $null) -and 
        ($_.SamAccountName -notin $ExcludedUsers) 
    })

if ($InactiveUsers.Count -gt 0) {
    foreach ($User in $InactiveUsers) {
        try {
            Disable-ADAccount -Identity $User.SAMAccountName
            Write-Log "Disabling User [ $($User.Name) - $($User.UserPrincipalName) ]"
        }
        catch {
            Write-Log "Failed to disable user [ $($User.Name) - $($User.UserPrincipalName) ]: $_"
        }
    }
}
else {
    Write-Log "All Users are active!"
}

$InactiveComputers = @(Get-ADComputer -Filter * -Properties LastLogonDate, Enabled | 
    Where-Object { 
        ($_.Enabled -eq $True) -and 
        ($_.LastLogonDate -lt $TimeStamp) -and 
        ($_.LastLogonDate -ne $null) -and 
        ($_.Name -notin $ExcludedComputers) -and 
        ($_.CN -ne "AZUREADSSOACC") 
    })

if ($InactiveComputers.Count -gt 0) {
    foreach ($Computer in $InactiveComputers) {
        try {
            Disable-ADComputer -Identity $Computer
            Write-Log "Disabling Computer [ $($Computer.Name) ]"
        }
        catch {
            Write-Log "Failed to disable computer [ $($Computer.Name) ]: $_"
        }
    }
}
else {
    Write-Log "All Computers are active!"
}

$InactiveUsersOUName = 'Disabled Users'
$InactiveComputersOUName = 'Disabled Computers'

Write-Log "Moving disabled users and computers to OUs: $InactiveUsersOUName and $InactiveComputersOUName"

$InactiveUsersOU = Get-ADOrganizationalUnit -Filter * | Where-Object { $_.Name -eq $InactiveUsersOUName }
$InactiveComputersOU = Get-ADOrganizationalUnit -Filter * | Where-Object { $_.Name -eq $InactiveComputersOUName }

if (!$InactiveUsersOU) {
    try {
        $InactiveUsersOU = New-ADOrganizationalUnit -Name $InactiveUsersOUName -ProtectedFromAccidentalDeletion $True
        Write-Log "Created OU: $InactiveUsersOUName"
    }
    catch {
        Write-Log "Failed to create OU: $InactiveUsersOUName"
    }
}

if (!$InactiveComputersOU) {
    try {
        $InactiveComputersOU = New-ADOrganizationalUnit -Name $InactiveComputersOUName -ProtectedFromAccidentalDeletion $True
        Write-Log "Created OU: $InactiveComputersOUName"
    }
    catch {
        Write-Log "Failed to create OU: $InactiveComputersOUName"
    }
}

$DisabledUsers = @(Get-ADUser -Filter * -Properties Enabled, DistinguishedName | 
    Where-Object { 
        ($_.Enabled -eq $False) -and 
        ($_.DistinguishedName -notlike $('*' + $($InactiveUsersOU.DistinguishedName))) 
    })

if ($DisabledUsers.count -ne 0) {
    foreach ($User in $DisabledUsers) {
        try {
            Move-ADObject -Identity $($User.DistinguishedName) -TargetPath $($InactiveUsersOU.DistinguishedName)
            Write-Log "Moved User [ $($User.Name) - $($User.UserPrincipalName) ] to $InactiveUsersOUName OU"
        }
        catch {
            Write-Log "Failed to move User [ $($User.Name) - $($User.UserPrincipalName) ]: $_"
        }
    }
}
else {
    Write-Log "Nothing to transfer to $InactiveUsersOUName OU!"
}

$DisabledComputers = @(Get-ADComputer -Filter * -Properties Enabled, DistinguishedName | 
    Where-Object { 
        ($_.Enabled -eq $False) -and 
        ($_.DistinguishedName -notlike $('*' + $($InactiveComputersOU.DistinguishedName))) 
    })

if ($DisabledComputers.count -ne 0) {
    foreach ($Computer in $DisabledComputers) {
        try {
            Move-ADObject -Identity $($Computer.DistinguishedName) -TargetPath $($InactiveComputersOU.DistinguishedName)
            Write-Log "Moved Computer [ $($Computer.Name) ] to $InactiveComputersOUName OU"
        }
        catch {
            Write-Log "Failed to move Computer [ $($Computer.Name) ]: $_"
        }
    }
}
else {
    Write-Log "Nothing to transfer to $InactiveComputersOUName OU!"
}