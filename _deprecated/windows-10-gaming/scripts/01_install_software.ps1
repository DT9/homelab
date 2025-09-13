# 01_install_software.ps1
# Installs common utilities and software using Chocolatey.

# Function to install a package and check for success
function Install-ChocoPackage {
    param(
        [string]$PackageName
    )
    Write-Host "Installing $PackageName..."
    choco install $PackageName -y --force --limit-output --no-progress
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$PackageName installation failed with exit code $LASTEXITCODE."
    } else {
        Write-Host "$PackageName installed successfully."
    }
}

# --- Common Utilities ---
Install-ChocoPackage "7zip"
Install-ChocoPackage "notepadplusplus"
Install-ChocoPackage "git"
Install-ChocoPackage "microsoft-windows-terminal"
Install-ChocoPackage "powertoys"
Install-ChocoPackage "sysinternals"

# --- Browsers ---
Install-ChocoPackage "googlechrome"
Install-ChocoPackage "firefox"

# --- Developer Tools ---
Install-ChocoPackage "vscode"
Install-ChocoPackage "docker-desktop"

# --- Gaming ---
# Note: Installing gaming clients might require GUI interaction for logins.
# This is best done on first use of the image, but the installers can be pre-loaded.
Write-Host "Installing gaming software..."
Install-ChocoPackage "steam-client"
Install-ChocoPackage "epicgameslauncher"

# --- Winget (as an alternative or supplement) ---
# Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.201" -Force
# Install-Module -Name "Microsoft.WinGet.Client" -Force
# winget install "Some.App" --accept-package-agreements --accept-source-agreements

Write-Host "Software installation complete." 