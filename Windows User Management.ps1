# A collection of commands that I've found useful for searching through AD and local users


# AD account management

    # Get Ad users with info
    Get-ADUser -Filter * -Properties * | select SamAccountName,Enabled,LastBadPasswordAttempt,BadPwdCount,LogonCount,LastLogonDate,ScriptPath,pwdLastSet,PasswordNotRequired,PasswordLastSet | sort LastBadPasswordAttempt | ft

    # Get which users are admins
    (Get-ADGroup -Filter "SamAccountName -like '*admin*' -or SamAccountName -like '*operator*'").SamAccountName | % {Get-ADGroupMember -Identity $_ -Recursive} | group SamAccountName | %{$_.Name}

    # Disable an AD Account
    Disable-ADAccount -Identity 'userName'

    # Set password for AD account
    Set-ADAccountPassword -Identity 'userName' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force)



# Local User account management
    
    # Get local users with info
    Get-LocalUser | select Name,Enabled,LastLogon,PasswordLastSet,PasswordRequired,UserMayChangePassword | sort Enabled -Descending | ft

    # Get admin users
    Get-LocalGroupMember -Group Administrators | select Name


# Other Commands
    # List Users logged on
    quser
    # Log a user off, session number from quser command
    logoff {sessionNumber}


    # Create a log of every user login
    $trigger = New-JobTrigger -AtLogon
    $script = {"User $env:USERNAME logged in at $(Get-Date -Format 'H:mm:ss')" | Out-File -FilePath C:\Temp\Login.log -Append}
    Register-ScheduleJob -Name Log_Login -ScriptBlock $script -Trigger $trigger


# Loop For AD Server
do {
    Write-Host "`n---------------- $(Get-Date) -------------------"

    Write-Host "----------------- AD Users -------------------"
    Get-ADUser -Filter * -Properties * | select SamAccountName,Enabled,LastBadPasswordAttempt,BadPwdCount,LogonCount,LastLogonDate,ScriptPath,PasswordNotRequired,PasswordLastSet | sort LastBadPasswordAttempt -Descending | ft

    Write-Host "----------------- Admin Users -------------------"
    (Get-ADGroup -Filter "SamAccountName -like '*admin*' -or SamAccountName -like '*operator*'").SamAccountName | % {Get-ADGroupMember -Identity $_ -Recursive} | group SamAccountName | %{$_.Name}

    Write-Host "--------------------------------------`n"
    Start-Sleep -s 30

} while ($true)


# Loop For local users
do {
    Write-Host "`n---------------- $(Get-Date) -------------------"

    Write-Host "----------------- local Users -------------------"
    Get-LocalUser | select Name,Enabled,LastLogon,PasswordLastSet,PasswordRequired,UserMayChangePassword | sort Enabled -Descending | ft

    Write-Host "----------------- Admin Users -------------------"
    Get-LocalGroupMember -Group Administrators | select Name

    Write-Host "--------------------------------------`n"
    Start-Sleep -s 5

} while ($true)