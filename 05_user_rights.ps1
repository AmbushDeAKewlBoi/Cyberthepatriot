# ==========================================
# CIS Windows Server 2025
# Script 05: User Rights Assignment (Secedit)
# ==========================================

Write-Host "[+] Applying CIS User Rights Assignments..." -ForegroundColor Cyan

$infPath = "$env:TEMP\cis_user_rights.inf"

@"
[Unicode]
Unicode=yes

[Version]
signature=`"$CHICAGO$`"
Revision=1

[Privilege Rights]

; --- Network & Logon Rights ---
SeNetworkLogonRight = *S-1-5-32-544
SeDenyNetworkLogonRight = *S-1-5-32-546,*S-1-5-7

SeInteractiveLogonRight = *S-1-5-32-544
SeDenyInteractiveLogonRight = *S-1-5-32-546,*S-1-5-7

SeRemoteInteractiveLogonRight = *S-1-5-32-544
SeDenyRemoteInteractiveLogonRight = *S-1-5-32-546,*S-1-5-7

; --- System Privileges ---
SeBackupPrivilege = *S-1-5-32-544
SeRestorePrivilege = *S-1-5-32-544
SeTakeOwnershipPrivilege = *S-1-5-32-544
SeLoadDriverPrivilege = *S-1-5-32-544
SeSystemtimePrivilege = *S-1-5-32-544
SeTimeZonePrivilege = *S-1-5-32-544
SeCreateGlobalPrivilege = *S-1-5-32-544
SeSecurityPrivilege = *S-1-5-32-544

"@ | Set-Content $infPath -Encoding Unicode

# Apply security template
secedit /configure `
    /db secedit.sdb `
    /cfg $infPath `
    /areas USER_RIGHTS `
    /quiet

# Cleanup
Remove-Item $infPath -Force

Write-Host "[+] Script 05 complete." -ForegroundColor Green
