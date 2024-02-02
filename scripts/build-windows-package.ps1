<#
.SYNOPSIS
    This script used to building the Windows release binary 
    
.AUTHOR
    BobOng

.VERSION
    0.0.1

.LASTMODIFIED
    2024-02-02

#>

# Build windows package
flutter clean
flutter build windows

$root_dir = "$(pwd)"
$work_dir = "$root_dir\publish"
$starcoin_node_url = "https://github.com/starcoinorg/starcoin/releases/download/v2.0.3-alpha/starcoin-windows-latest.zip"

if (Test-Path $work_dir -PathType Container) {
    Remove-Item -Path $work_dir -Recurse -Force
}

New-Item -Path $work_dir -ItemType Directory

# Download the starcoin latest version
Invoke-WebRequest -Uri $starcoin_node_url -OutFile "$work_dir\starcoin-windows-latest.zip"
Expand-Archive -Path "$work_dir\starcoin-windows-latest.zip" -DestinationPath "$work_dir\starcoin" -Force
Remove-Item -Path "$work_dir\starcoin-windows-latest.zip" -Force

# Compress zip 
Compress-Archive -Path ("$root_dir\build\windows\runner\Release", "$work_dir\starcoin") -DestinationPath "$work_dir\starcoin_node_gui_windows.zip"
