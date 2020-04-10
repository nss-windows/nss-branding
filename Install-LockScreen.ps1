# Import as a standard application in MDT.
# Quiet install command: PowerShell.exe -ExecutionPolicy Bypass -NoProfile -Command .\Install-LockScreen.ps1

# Log
$LogPath = "C:\NSS\Logs\"
If (!(Test-Path "$LogPath")) {New-Item -ItemType Directory -Force -Path "$LogPath"}
$scriptname = [io.path]::GetFileNameWithoutExtension("$($MyInvocation.MyCommand.Name)")
$TransactionLog = $LogPath + $(Get-Date -Format yyyyMMdd) + "_" + $scriptname + ".log"
Start-Transcript -LiteralPath $TransactionLog

$AppFolder = "NSS\Branding"
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
# Take ownership of the existing lock screen files
takeown /f C:\Windows\Web\Screen\*

# Assign full permissions to the existing lock screen files to Administrators
& icacls C:\Windows\Web\Screen\* /Grant Administrators:`(F`)

# Delete the existing files
Remove-Item C:\Windows\Web\Screen\*

# Copy our new lock screen files to the proper location
Copy-Item "$env:SystemDrive\$AppFolder\images\lockscreen\img100.jpg" "C:\Windows\Web\Screen"

# Add the registry key so the lock screen is set to the image we copied
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization /v LockScreenImage /t REG_SZ /d "C:\Windows\Web\Screen\img100.jpg"

# Give ownership back to Trusted Installer
& icacls C:\Windows\Web\Screen\* /setowner "NT SERVICE\TrustedInstaller"

Stop-Transcript