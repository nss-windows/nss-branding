<#
.SYNOPSIS
Sets the default desktop background for all users.

.DESCRIPTION
This script replaces the default background images on Windows 10 with an alternate set. 

.NOTES   
Name       : Install-DefaultBackground.ps1
Author     : Darren Hollinrake
Version    : 1.0
DateCreated: 2018-04-01
DateUpdated: 2020-05-21

MDT Use:
Import as a standard application in MDT. The folder containing the script will be the source used for importing.

Quiet install command: PowerShell.exe -ExecutionPolicy Bypass -NoProfile -Command .\Install-DefaultBackground.ps1

#>

# Log
$LogPath = "C:\NSS\Logs\"
If (!(Test-Path "$LogPath")) {New-Item -ItemType Directory -Force -Path "$LogPath"}
$scriptname = [io.path]::GetFileNameWithoutExtension("$($MyInvocation.MyCommand.Name)")
$TransactionLog = $LogPath + $(Get-Date -Format yyyyMMdd) + "_" + $scriptname + ".log"
Start-Transcript -LiteralPath $TransactionLog

$AppFolder = "NSS\Branding\background"
#
# Create the App Directory
If(!(Test-Path "$env:SystemDrive\$AppFolder")) {
    New-Item -ItemType Directory -Path "$env:SystemDrive\$AppFolder"
}

# Copy the folder to the local system
Copy-Item "$PSScriptRoot\*" "$env:SystemDrive\$AppFolder" -Force -Recurse

# Take ownership of the existing wallpaper files
takeown /f C:\Windows\Web\4K\Wallpaper\Windows\*
takeown /f C:\Windows\Web\Wallpaper\Windows\img0.jpg

# Assign full permissions to the existing wallpaper files to Administrators
& icacls C:\Windows\Web\Wallpaper\Windows\img0.jpg /Grant Administrators:`(F`)
& icacls C:\Windows\Web\4K\Wallpaper\Windows\* /Grant Administrators:`(F`)

# Delete the existing files
Remove-Item C:\Windows\Web\4K\Wallpaper\Windows\*
Remove-Item C:\Windows\Web\Wallpaper\Windows\img0.jpg

# Copy our new wallpaper files to the proper location
Copy-Item "$env:SystemDrive\$AppFolder\img\background\img0.jpg" "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
Copy-Item "$env:SystemDrive\$AppFolder\img\img0_*.jpg" "C:\Windows\Web\4K\Wallpaper\Windows"

# Give ownership back to Trusted Installer
& icacls C:\Windows\Web\Wallpaper\Windows\img0.jpg /setowner "NT SERVICE\TrustedInstaller"
& icacls C:\Windows\Web\4K\Wallpaper\Windows\* /setowner "NT SERVICE\TrustedInstaller"

Stop-Transcript