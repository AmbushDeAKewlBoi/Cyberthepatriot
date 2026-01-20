# ==========================================
# CIS Windows Server 2025
# Script 03: Firewall, Services, Network
# ==========================================

Write-Host "[+] Applying CIS Firewall, Services, and Network Hardening..." -ForegroundColor Cyan

# --------------------------------------------------
# Firewall Profile Configuration Function
# --------------------------------------------------

function Set-FirewallProfile {
    param (
        [string]$Profile
    )

    Write-Host "  - Configuring $Profile firewall profile"

    Set-NetFirewallProfile -Profile $Profile `
        -Enabled True `
        -DefaultInboundAction Block `
        -DefaultOutboundAction Allow `
        -NotifyOnListen False `
        -AllowLocalFirewallRules True `
        -AllowLocalIPsecRules True `
        -LogAllowed True `
        -LogBlocked True `
        -LogFileName "%SystemRoot%\System32\LogFiles\Firewall\$Profile.log" `
        -LogMaxSizeKilobytes 16384
}

# ----------------------------
# CIS Section 9 – Firewall
# ----------------------------

Set-FirewallProfile -Profile Domain
Set-FirewallProfile -Profile Private
Set-FirewallProfile -Profile Public

# Ensure firewall is enabled globally
netsh advfirewall set allprofiles state on > $null

# ----------------------------
# CIS Section 5 – Services
# ----------------------------

Write-Host "  - Disabling Print Spooler service"

$spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
if ($spooler) {
    if ($spooler.Status -ne "Stopped") {
        Stop-Service -Name Spooler -Force
    }
    Set-Service -Name Spooler -StartupType Disabled
}

# ----------------------------
# CIS 18.9 – Network Hardening
# ----------------------------

Write-Host "  - Disabling multicast name resolution (LLMNR)"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
    /v EnableMulticast `
    /t REG_DWORD `
    /d 0 `
    /f > $null

Write-Host "  - Disabling NetBIOS over TCP/IP (where applicable)"

$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE"
foreach ($adapter in $adapters) {
    try {
        $adapter.SetTcpipNetbios(2) | Out-Null
    } catch {
        # Ignore adapters that refuse changes
    }
}

# ----------------------------
# Firewall Logging Folder Check
# ----------------------------

$logPath = "$env:SystemRoot\System32\LogFiles\Firewall"
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

# Secure permissions on firewall logs
icacls $logPath /inheritance:r > $null
icacls $logPath /grant "SYSTEM:(OI)(CI)F" > $null
icacls $logPath /grant "Administrators:(OI)(CI)F" > $null

Write-Host "[+] Script 03 complete." -ForegroundColor Green
