# ================================
# CIS Windows Server 2025
# Script 02: Advanced Audit Policy
# ================================

Write-Host "[+] Applying CIS Advanced Audit Policies..." -ForegroundColor Cyan

# ------------------------------------------------
# Enforce Advanced Audit Policy over legacy policy
# CIS 2.3.2.1
# ------------------------------------------------

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" `
    /v SCENoApplyLegacyAuditPolicy `
    /t REG_DWORD `
    /d 1 `
    /f > $null

# ----------------------------
# Helper function
# ----------------------------

function Set-Audit {
    param (
        [string]$Category,
        [string]$Setting
    )
    auditpol /set /subcategory:"$Category" /success:$($Setting -match "Success") /failure:$($Setting -match "Failure") > $null
}

# ----------------------------
# 17.1 Account Logon
# ----------------------------

Set-Audit "Credential Validation" "Success and Failure"

# DC-only (safe to run on MS; ignored)
Set-Audit "Kerberos Authentication Service" "Success and Failure"
Set-Audit "Kerberos Service Ticket Operations" "Success and Failure"

# ----------------------------
# 17.2 Account Management
# ----------------------------

Set-Audit "Application Group Management" "Success and Failure"
Set-Audit "Computer Account Management" "Success"
Set-Audit "Distribution Group Management" "Success"
Set-Audit "Other Account Management Events" "Success"
Set-Audit "Security Group Management" "Success"
Set-Audit "User Account Management" "Success and Failure"

# ----------------------------
# 17.3 Detailed Tracking
# ----------------------------

Set-Audit "Plug and Play Events" "Success"
Set-Audit "Process Creation" "Success"

# ----------------------------
# 17.4 DS Access (DC only)
# ----------------------------

Set-Audit "Directory Service Access" "Failure"
Set-Audit "Directory Service Changes" "Success"

# ----------------------------
# 17.5 Logon / Logoff
# ----------------------------

Set-Audit "Account Lockout" "Failure"
Set-Audit "Group Membership" "Success"
Set-Audit "Logoff" "Success"
Set-Audit "Logon" "Success and Failure"
Set-Audit "Other Logon/Logoff Events" "Success and Failure"
Set-Audit "Special Logon" "Success"

# ----------------------------
# 17.6 Object Access
# ----------------------------

Set-Audit "Detailed File Share" "Failure"
Set-Audit "File Share" "Success and Failure"
Set-Audit "Other Object Access Events" "Success and Failure"
Set-Audit "Removable Storage" "Success and Failure"

# ----------------------------
# 17.7 Policy Change
# ----------------------------

Set-Audit "Audit Policy Change" "Success"
Set-Audit "Authentication Policy Change" "Success"
Set-Audit "Authorization Policy Change" "Success"
Set-Audit "MPSSVC Rule-Level Policy Change" "Success and Failure"
Set-Audit "Other Policy Change Events" "Failure"

# ----------------------------
# 17.8 Privilege Use
# ----------------------------

Set-Audit "Sensitive Privilege Use" "Success and Failure"

# ----------------------------
# 17.9 System
# ----------------------------

Set-Audit "IPsec Driver" "Success and Failure"
Set-Audit "Other System Events" "Success and Failure"
Set-Audit "Security State Change" "Success"
Set-Audit "Security System Extension" "Success"
Set-Audit "System Integrity" "Success and Failure"

Write-Host "[+] Script 02 complete." -ForegroundColor Green
