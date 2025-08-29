# 05_validation.ps1
# Performs post-build validation checks inside the VM before Sysprep.

Write-Output "Starting post-build validation..."

$validation_results = @{}

# --- 1. Check Hardening Status ---
Write-Output "Validating security settings..."
try {
    # Check SMBv1 status
    $smb1 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" | Select-Object -ExpandProperty SMB1
    $validation_results["SMBv1 Disabled"] = ($smb1 -eq 0)

    # Check Credential Guard status
    $lsacfg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" | Select-Object -ExpandProperty LsaCfgFlags
    $validation_results["Credential Guard Enabled"] = ($lsacfg -eq 1)

    # Check Guest account status
    $guest_active = (Get-LocalUser -Name "Guest").Enabled
    $validation_results["Guest Account Disabled"] = (-not $guest_active)
}
catch {
    Write-Warning "Could not validate all hardening settings. Error: $_"
}

# --- 2. Run Windows Defender Scan ---
Write-Output "Starting Windows Defender scan (quick scan)..."
Start-MpScan -ScanType QuickScan
$threats = Get-MpThreatDetection
if ($null -eq $threats) {
    $validation_results["Windows Defender Scan"] = "Passed (No Threats)"
    Write-Output "Defender scan complete. No threats found."
} else {
    $validation_results["Windows Defender Scan"] = "Failed (Threats Detected)"
    Write-Warning "Threats detected by Windows Defender!"
    $threats | Format-List
}

# --- 3. Dump Local Security Policy ---
Write-Output "Dumping local security policy to C:\Windows\Temp\policy.inf"
secedit /export /cfg C:\Windows\Temp\policy.inf /quiet
if (Test-Path "C:\Windows\Temp\policy.inf") {
    $validation_results["Local Policy Dump"] = "Success"
} else {
    $validation_results["Local Policy Dump"] = "Failed"
}

# --- 4. Output Results ---
Write-Output "--- Validation Summary ---"
$validation_results.GetEnumerator() | ForEach-Object {
    Write-Output "$($_.Name): $($_.Value)"
}
Write-Output "------------------------"

# Fail the build if a critical validation fails
if ($validation_results["SMBv1 Disabled"] -ne $true -or $validation_results["Guest Account Disabled"] -ne $true) {
    Write-Error "Critical validation check failed. Aborting build."
    exit 1
}

Write-Output "Validation script finished." 