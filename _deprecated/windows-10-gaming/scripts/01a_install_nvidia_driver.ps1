# 01a_install_nvidia_driver.ps1
# Downloads and silently installs NVIDIA Game Ready drivers.

Write-Output "Starting NVIDIA driver installation..."

# NOTE: This URL may become outdated. Please update it with the latest driver link from the NVIDIA website.
# You can find the latest drivers here: https://www.nvidia.com/en-us/geforce/drivers/
$driverUrl = "https://us.download.nvidia.com/Windows/552.22/552.22-desktop-win10-win11-64bit-international-dch-whql.exe" # Example URL for version 552.22
$driverPath = "$($env:TEMP)\nvidia_driver.exe"

# Download the driver
Write-Output "Downloading NVIDIA driver from $driverUrl..."
try {
    Invoke-WebRequest -Uri $driverUrl -OutFile $driverPath -UseBasicParsing
    Write-Output "NVIDIA driver downloaded successfully."
} catch {
    Write-Error "Failed to download NVIDIA driver. Error: $_"
    exit 1
}

# Install the driver silently
# Arguments:
# -s : Silent mode
# -clean : Performs a clean installation, removing previous driver versions and profiles.
# -noreboot : Prevents the system from rebooting after installation. Packer will handle reboots if needed.
Write-Output "Installing NVIDIA driver silently..."
$arguments = "-s -clean -noreboot"
$process = Start-Process -FilePath $driverPath -ArgumentList $arguments -Wait -PassThru

if ($process.ExitCode -ne 0) {
    # Exit codes can be non-zero even on success if a reboot is required (3010).
    # We will let Packer handle the reboot.
    Write-Warning "NVIDIA driver installation finished with a non-zero exit code: $($process.ExitCode). This may be expected if a reboot is required."
} else {
    Write-Output "NVIDIA driver installed successfully."
}

# Clean up the installer
Write-Output "Removing NVIDIA driver installer..."
Remove-Item -Path $driverPath -Force

Write-Output "NVIDIA driver installation script finished." 