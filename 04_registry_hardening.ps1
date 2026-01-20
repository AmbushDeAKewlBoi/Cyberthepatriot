# ==========================================
# CIS Windows Server 2025
# Script 04: Registry Hardening
# ==========================================

Write-Host "[+] Applying CIS Registry Hardening..." -ForegroundColor Cyan

# ----------------------------
# Helper function
# ----------------------------

function Set-Reg {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    reg add $Path /v $Name /t REG_DWORD /d $Value /f > $null
}

# ----------------------------
# Disable SMBv1 (CIS 18.3)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\mrxsmb10" "Start" 4

# ----------------------------
# SMB Signing (CIS 2.3.10)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "RequireSecuritySignature" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "EnableSecuritySignature" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnableSecuritySignature" 1

# ----------------------------
# NTLM Hardening (CIS 2.3.11)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymousSAM" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "EveryoneIncludesAnonymous" 0
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "UseMachineId" 1

# ----------------------------
# Disable WDigest (CIS 18.4)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential" 0

# ----------------------------
# Cleartext credential storage
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1

# ----------------------------
# Kerberos Hardening (CIS 2.3.6)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483644

# ----------------------------
# UAC Core Protections (CIS 2.3.17)
# ----------------------------

Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1
Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 2
Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" 1
Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableInstallerDetection" 1
Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableSecureUIAPaths" 1
Set-Reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 1

# ----------------------------
# MSS (Microsoft Security Settings)
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NoNameReleaseOnDemand" 1
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 2
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "PerformRouterDiscovery" 0
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "KeepAliveTime" 300000

# ----------------------------
# Anonymous Pipes & Shares
# ----------------------------

Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "NullSessionShares" 0
Set-Reg "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "NullSessionPipes" 0

Write-Host "[+] Script 04 complete." -ForegroundColor Green
