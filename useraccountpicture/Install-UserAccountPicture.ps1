# Import as a standard application in MDT.
# Quiet install command: PowerShell.exe -ExecutionPolicy Bypass -NoProfile -Command .\Install-UserAccountPicture.ps1

#Log
$LogPath = "C:\NSS\Logs\"
If (!(Test-Path "$LogPath")) {New-Item -ItemType Directory -Force -Path "$LogPath"}
$scriptname = [io.path]::GetFileNameWithoutExtension("$($MyInvocation.MyCommand.Name)")
$TransactionLog = $LogPath + $(Get-Date -Format yyyyMMdd) + "_" + $scriptname + ".log"
Start-Transcript -LiteralPath $TransactionLog

$AppFolder = "NSS\Branding\useraccountpicture"
# Ensure we have our task sequence variables available
Import-Module $env:SystemDrive\MININT\Modules\ZTIUtility
#
# Create the App Directory
If(!(Test-Path "$env:SystemDrive\$AppFolder")) {
    New-Item -ItemType Directory -Path "$env:SystemDrive\$AppFolder"
}

# Copy the folder to the local system
Copy-Item "$PSScriptRoot\*" "$env:SystemDrive\$AppFolder" -Force -Recurse

# Apply the image as the lock screen
# Take ownership of the existing account pictures
takeown /f "$env:ProgramData\Microsoft\User Account Pictures\*"

# Assign full permissions to the existing lock screen files to Administrators
& icacls "$env:ProgramData\Microsoft\User Account Pictures\*" /Grant Administrators:`(F`)

# Delete the existing files
Remove-Item "$env:ProgramData\Microsoft\User Account Pictures\user*"

# Copy our new lock screen files to the proper location
Copy-Item "$env:SystemDrive\$AppFolder\img\useraccountpicture\*" "$env:ProgramData\Microsoft\User Account Pictures"

# Add the registry key to set the default account picture for all users
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v UseDefaultTile /t REG_DWORD /d 1

# Give ownership back to Trusted Installer
& icacls "$env:ProgramData\Microsoft\User Account Pictures\*" /setowner "NT SERVICE\TrustedInstaller"

Stop-Transcript