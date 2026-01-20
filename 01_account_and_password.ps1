# ================================
# CIS Windows Server 2025
# Script 01: Account & Password Policies
# ================================

Write-Host "[+] Applying CIS Account & Password Policies..." -ForegroundColor Cyan

# ----------------
# Password Policy
# ----------------

Write-Host "  - Configuring password policy"

net accounts `
    /uniquepw:24 `
    /maxpwage:365 `
    /minpwage:1 `
    /minpwlen:14 `
    /lockoutthreshold:0 > $null

# Enable password complexity
secedit /export /cfg "$env:TEMP\secpol.cfg" > $null

(Get-Content "$env:TEMP\secpol.cfg") `
    -replace 'PasswordComplexity\s*=\s*\d+', 'PasswordComplexity = 1' `
    -replace 'ClearTextPassword\s*=\s*\d+', 'ClearTextPassword = 0' `
    | Set-Content "$env:TEMP\secpol.cfg"

# Relax minimum password length limits
if (-not (Select-String "$env:TEMP\secpol.cfg" -Pattern "RelaxMinimumPasswordLengthLimits")) {
    Add-Content "$env:TEMP\secpol.cfg" "RelaxMinimumPasswordLengthLimits = 1"
}

secedit /configure /db secedit.sdb /cfg "$env:TEMP\secpol.cfg" /areas SECURITYPOLICY > $null

Remove-Item "$env:TEMP\secpol.cfg" -Force

# ------------------------
# Account Lockout Policy
# ------------------------

Write-Host "  - Configuring account lockout policy"

net accounts `
    /lockoutthreshold:5 `
    /lockoutduration:15 `
    /lockoutwindow:15 > $null

# ----------------------------------
# CIS 2.3.1 Accounts Security Options
# ----------------------------------

Write-Host "  - Configuring account security options"

# Disable Guest account
$guest = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
if ($guest -and $guest.Enabled) {
    Disable-LocalUser -Name "Guest"
}

# Limit blank passwords to console logon only
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" `
    /v LimitBlankPasswordUse `
    /t REG_DWORD `
    /d 1 `
    /f > $null

Write-Host "[+] Script 01 complete." -ForegroundColor Green
