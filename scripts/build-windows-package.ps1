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

# # Build windows package
# flutter clean
# flutter build windows

$root_dir = "$(pwd)"
$work_dir = "$root_dir\publish"
$package_dir = "$work_dir\starcoin_node_gui"
$starcoin_node_url = "https://github.com/starcoinorg/starcoin/releases/download/v2.0.3-alpha/starcoin-windows-latest.zip"

if (Test-Path $work_dir -PathType Container) {
    Remove-Item -Path $work_dir -Recurse -Force
}

New-Item -Path $work_dir -ItemType Directory

## Download the starcoin latest version
$starcoin_zip = "$work_dir\starcoin-windows-latest.zip"
Invoke-WebRequest -Uri $starcoin_node_url -OutFile $starcoin_zip

$retryCount = 0
$maxRetries = 4

while ($retryCount -lt $maxRetries -and -not (Test-Path -Path $starcoin_zip)) {
    $retryCount ++

    Write-Host "File download failed, try to download again, retry times: $retryCount ..."
    Invoke-WebRequest -Uri $starcoin_node_url -OutFile $starcoin_zip

    Start-Sleep -Seconds 5
}

# Check file is exist
if (!(Test-Path -Path $starcoin_zip)) {
    Write-Error "File download failed, the maximum number of retries has been reached: $maxRetries"
    exit 1
}

Expand-Archive -Path "$work_dir\starcoin-windows-latest.zip" -DestinationPath "$work_dir\starcoin" -Force
Remove-Item -Path "$work_dir\starcoin-windows-latest.zip" -Force


# Copy files
New-Item -Path "$package_dir" -ItemType Directory
Copy-Item -Path "$root_dir\build\windows\runner\Release\*" -Destination "$package_dir" -Recurse -Force

New-Item -Path "$package_dir\starcoin" -ItemType Directory
Copy-Item -Path "$work_dir\starcoin\starcoin-artifacts\*" -Destination "$package_dir\starcoin" 

# Compress zip
Compress-Archive -Path $package_dir -DestinationPath "${package_dir}_windows.zip"

Write-Output "Done!! Output dir: ${package_dir}_windows.zip"