# This script is executed by Autounattend.xml during the first logon.
# It configures WinRM to allow Packer to connect and provision the VM.

# Set network to private to ensure WinRM firewall rules apply correctly
Set-NetConnectionProfile -Name "Ethernet" -NetworkCategory Private

# Configure WinRM service
winrm quickconfig -q
winrm set winrm/config/service/Auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# Set firewall rule for WinRM
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes

# Set PowerShell execution policy
Set-ExecutionPolicy Unrestricted -Force

# Disable complex passwords for simplicity in a non-domain environment.
# This allows the simple password in Autounattend.xml to be set.
# CIS hardening script will enforce a strong password policy later.
secedit /export /cfg C:\windows\temp\secpol.cfg
(gc C:\windows\temp\secpol.cfg) -replace "PasswordComplexity = 1", "PasswordComplexity = 0" | Out-File C:\windows\temp\secpol.cfg -Encoding "ascii"
secedit /configure /db c:\windows\security\local.sdb /cfg C:\windows\temp\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\windows\temp\secpol.cfg -Force

Write-Output "WinRM configured." 