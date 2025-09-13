# 04_cleanup.ps1
# Performs final cleanup, zeros free space, and runs Sysprep.

Write-Output "Starting final system cleanup..."

# Clear event logs
wevtutil el | Foreach-Object { wevtutil cl "$_" }

# Clear temporary files
Remove-Item -Path "$($env:TEMP)\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear Chocolatey temp files
Remove-Item -Path "$($env:ProgramData)\chocolatey\lib\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$($env:ProgramData)\chocolatey\temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Zero out free space using SDelete
# Packer will handle downloading and executing this
# sdelete.exe -z C:

# --- Run Sysprep ---
# This command generalizes the image for deployment.
# It should be the LAST step in provisioning.
Write-Output "Running Sysprep..."
& "C:\Windows\System32\Sysprep\Sysprep.exe" /generalize /oobe /shutdown /quiet

# Wait for shutdown to complete
Start-Sleep -Seconds 120 