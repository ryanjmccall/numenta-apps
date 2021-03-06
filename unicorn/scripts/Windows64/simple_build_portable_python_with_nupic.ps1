﻿# See README.md for instructions about prerequisites and how to run this script.

param (
    [string]$nupic_version = "0.3.6"
)

# Make the script fail on cmlets errors
$ErrorActionPreference = "Stop"

$script_path = split-path -parent $MyInvocation.MyCommand.Definition

# Python
$python_version = "2.7.11"
$portable_python_dir = "portable_python"
$python_msi_url = "https://www.python.org/ftp/python/$python_version/python-$python_version.amd64.msi"
$python_msi = "python-$python_version.amd64.msi"

# Pip
$get_pip_url = "https://bootstrap.pypa.io/get-pip.py"
$get_pip = "get-pip.py"

Write-Host "==> Uninstalling Python ..."
Start-Process  -Wait -FilePath msiexec -ArgumentList /x, $python_msi, /passive, /norestart

Write-Host "==> Cleaning up files and directories ..."

Remove-Item -Force -ErrorAction Ignore $python_msi
Remove-Item -Force -ErrorAction Ignore $get_pip
Remove-Item -Force -ErrorAction Ignore $portable_python_dir -Recurse
Remove-Item -Force -ErrorAction Ignore "$portable_python_dir.zip"

New-Item $portable_python_dir -type Directory | Out-Null

Write-Host "==> Downloading Python ..."
Invoke-WebRequest -Uri $python_msi_url -OutFile $script_path\$python_msi

Write-Host "==> Installing Python ..."
Start-Process -Wait -FilePath msiexec -ArgumentList /a, $python_msi, ALLUSERS=0, TARGETDIR=$script_path\$portable_python_dir, /passive, /norestart

Write-Host "==> Downloading get-pip.py ..."
Invoke-WebRequest -Uri $get_pip_url -OutFile $get_pip

Write-Host "==> Installing pip ..."
Invoke-Expression "$script_path\$portable_python_dir\python.exe $get_pip"

Write-Host "==> Installing nupic wheel ..."
Invoke-Expression "$portable_python_dir\Scripts\pip.exe install nupic==$nupic_version"

Write-Host "==> Testing that nupic and nupic.bindings were succesfully installed ..."
$test_nupic_bindings_import = "$portable_python_dir\python.exe -c 'import nupic.bindings.math'"
$test_nupic_import = "$portable_python_dir\python.exe -c 'import nupic.algorithms.anomaly_likelihood'"
Write-Host $test_nupic_bindings_import
Write-Host $test_nupic_import
Invoke-Expression $test_nupic_bindings_import
Invoke-Expression $test_nupic_import

# PowerShell Community Extensions (PSCX): Write-Tar, Write-GZip
if (Get-Module -ListAvailable -Name Pscx) {
    Import-Module Pscx
} else {
    Write-Host "Installing PowerShell Community Extensions (PSCX)"
    Invoke-WebRequest -Uri https://pscx.codeplex.com/downloads/get/923562 -OutFile "$script_path/pscx.msi"
    Start-Process -Wait -FilePath msiexec -ArgumentList /i, "$script_path\pscx.msi", /qn, /passive, ALLUSERS=0
    Remove-Item -Force -ErrorAction Ignore "$script_path\pscx.msi"
    $env:psmodulepath = $env:psmodulepath + ";${env:ProgramFiles(x86)}\PowerShell Community Extensions\Pscx3"
    Import-Module Pscx
}

Write-Host "==> Packaging portable_python artifact ..."
Copy-Item $script_path\index.js -destination $script_path/$portable_python_dir
Copy-Item $script_path\package.json -destination $script_path/$portable_python_dir
Write-Tar -path $script_path/$portable_python_dir -output $script_path/$portable_python_dir.tar
Write-Gzip -level 9 $script_path/$portable_python_dir.tar

Write-Host "==> Cleaning up ..."
Remove-Item -Force -ErrorAction Ignore $script_path/$portable_python_dir.tar
Remove-Item -Force -ErrorAction Ignore $python_msi
Remove-Item -Force -ErrorAction Ignore $get_pip
Remove-Item -Force -ErrorAction Ignore $portable_python_dir -Recurse
