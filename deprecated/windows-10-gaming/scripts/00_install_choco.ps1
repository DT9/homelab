# 00_install_choco.ps1
# Installs Chocolatey package manager.

Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
try {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} catch {
    Write-Host "Chocolatey installation failed."
    exit 1
}

# Add Chocolatey to the path for the current session
$env:Path += ";$($env:ProgramData)\chocolatey\bin"

Write-Host "Chocolatey installed successfully." 