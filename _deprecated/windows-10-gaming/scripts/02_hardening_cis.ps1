# 02_hardening_cis.ps1
# Applies security hardening settings based on CIS Benchmarks for Windows 10/11.
# This script uses PowerShell to modify registry keys and system settings.

Write-Output "Starting CIS Benchmark Hardening..."

# Function to set a registry key
function Set-RegKey {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    Write-Output "Set registry key: $Path\`$Name = $Value"
}

# --- 1. Account Policies ---
# CIS 1.1.1 - Enforce password history
Set-RegKey "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "PasswordHistorySize" 24
# CIS 1.1.2 - Maximum password age
secedit /export /cfg C:\temp.inf /areas SECURITYPOLICY
(Get-Content C:\temp.inf) -replace 'MaximumPasswordAge = \d+', 'MaximumPasswordAge = 60' | Set-Content C:\temp.inf
secedit /configure /db $env:windir\security\new.sdb /cfg C:\temp.inf /areas SECURITYPOLICY
# CIS 1.1.3 - Minimum password age
# CIS 1.1.4 - Minimum password length
# CIS 1.1.5 - Password must meet complexity requirements
# (These are often set via security templates for reliability)

# --- 2. Local Policies ---
# CIS 2.3.1.2 - Disable 'Guest' account status
net user guest /active:no
# CIS 2.3.1.4 - Rename administrator account
# net user Administrator "NewAdminName" # Example, should be parameterized

# --- SMB Hardening ---
# CIS 2.3.10.2 - Disable SMBv1
Set-RegKey "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0

# --- RDP Hardening ---
# CIS 5.2 - Limit RDP access
# This is often done by managing the "Remote Desktop Users" group.
# (net localgroup "Remote Desktop Users" "username" /delete)
# CIS 5.3 - Set encryption level to high
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MinEncryptionLevel" 3

# --- Credential Guard ---
# CIS - Enable Credential Guard (Requires Secure Boot and Virtualization)
# Note: This can cause issues with some software/drivers.
Set-RegKey "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LsaCfgFlags" 1 -Type DWord
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "LsaCfgFlags" 1 -Type DWord
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "EnableVirtualizationBasedSecurity" 1 -Type DWord
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "RequirePlatformSecurityFeatures" 3 -Type DWord

# --- Other Security Settings ---
# Disable autorun
Set-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255
Set-RegKey "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" "NoDriveTypeAutoRun" 255

# Enable PowerShell transcription and logging
$PSTranscriptionPath = "C:\Logs\PowerShellTranscripts"
If (-not (Test-Path $PSTranscriptionPath)) { New-Item -Path $PSTranscriptionPath -ItemType Directory -Force }
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" "EnableTranscripting" 1
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" "OutputDirectory" $PSTranscriptionPath -Type String
Set-RegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" "EnableInvocationHeader" 1

$PSModuleLogPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
Set-RegKey $PSModuleLogPath "EnableModuleLogging" 1
Set-RegKey "$PSModuleLogPath\ModuleNames" "*" "*" -Type String

# Install and configure Sysmon
# choco install sysmon -y
# sysmon -accepteula -i # (with a proper config file)

Write-Output "CIS Benchmark Hardening complete." 