# =============================================================================
# Lab 2: Active Directory Domain Services
# Author: Chinedu Asuzu | github.com/kingsrule50
#
# PREREQUISITE: Lab 1 (Azure Infrastructure) must be deployed first.
#
# USAGE: ./run-lab2.ps1
#
# This script orchestrates all Active Directory configuration in phases:
#   Phase 1 - Verify Lab 1 infrastructure is running
#   Phase 2 - Install AD DS feature on DC01
#   Phase 3 - Promote DC01 to Domain Controller
#   Phase 4 - Create OUs, Security Groups and User Accounts
#   Phase 5 - Configure Group Policy (RDP for domain users)
#   Phase 6 - Verify Active Directory configuration
# =============================================================================

$rg = "RG-FileServerLab"

# --- Retrieve admin credentials from Key Vault (created by Lab 1) ---
# The DSRM (Safe Mode) password for DC promotion is NOT stored in this repo.
Write-Host "Retrieving credentials from Azure Key Vault..." -ForegroundColor Yellow
$kvName = az keyvault list --resource-group $rg --query "[0].name" -o tsv
if (-not $kvName) {
    throw "No Key Vault found in $rg. Ensure Lab 1 is deployed."
}
$adminPassword = az keyvault secret show --vault-name $kvName --name "vm-admin-password" --query "value" -o tsv
if (-not $adminPassword) {
    throw "Could not retrieve 'vm-admin-password' from Key Vault '$kvName'."
}
Write-Host "  [+] Credentials retrieved from Key Vault: $kvName" -ForegroundColor Green

function Write-PhaseHeader {
    param([string]$Phase, [string]$Title, [string]$VM = "")
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host " $Phase - $Title" -ForegroundColor Magenta
    if ($VM) { Write-Host " Target VM: $VM" -ForegroundColor Magenta }
    Write-Host "============================================================" -ForegroundColor Magenta
}

function Invoke-VMScript {
    param(
        [string]$VMName,
        [string]$ScriptPath,
        [string[]]$Parameters = @()
    )
    # az's @file syntax: az reads the script file directly, avoiding Windows
    # cmd argument-length limits and quote/newline mangling that can silently
    # corrupt scripts passed as strings. Works identically on macOS/Linux.
    $fullPath = (Resolve-Path $ScriptPath -ErrorAction Stop).Path
    $azArgs = @(
        "vm", "run-command", "invoke",
        "--resource-group", $rg,
        "--name", $VMName,
        "--command-id", "RunPowerShellScript",
        "--scripts", "@$fullPath",
        "--output", "json",
        "--only-show-errors"
    )
    if ($Parameters.Count -gt 0) {
        $azArgs += "--parameters"
        $azArgs += $Parameters
    }
    $result = az @azArgs | ConvertFrom-Json
    $stdout = $result.value | Where-Object { $_.code -like "*StdOut*" } | Select-Object -ExpandProperty message
    $stderr = $result.value | Where-Object { $_.code -like "*StdErr*" } | Select-Object -ExpandProperty message
    if ($stdout) { Write-Host $stdout -ForegroundColor White }
    if ($stderr) { Write-Host "STDERR: $stderr" -ForegroundColor Yellow }
}

function Wait-ForNext {
    param([string]$NextPhase)
    Write-Host ""
    Read-Host "Press ENTER to proceed to $NextPhase"
}

# =============================================================================
# PHASE 1 - Verify Infrastructure
# =============================================================================
Write-PhaseHeader -Phase "PHASE 1" -Title "Verify Lab 1 Infrastructure"
Write-Host " Confirming all VMs are running before AD configuration begins..." -ForegroundColor White
& ./scripts/phase1-verify-infra.ps1 -ResourceGroup $rg
if ($LASTEXITCODE -ne 0) {
    Write-Host "Infrastructure not ready. Deploy Lab 1 first." -ForegroundColor Red
    exit 1
}
Wait-ForNext -NextPhase "Phase 2 - Install AD DS Feature"

# =============================================================================
# PHASE 2 - Install AD DS Feature on DC01
# =============================================================================
Write-PhaseHeader -Phase "PHASE 2" -Title "Install AD DS Feature" -VM "DC01"
Invoke-VMScript -VMName "DC01" -ScriptPath "./scripts/phase2-install-adds.ps1"

Write-Host ""
Write-Host "Rebooting DC01 to finalize AD DS feature installation..." -ForegroundColor Yellow
az vm restart --resource-group $rg --name DC01 | Out-Null
Write-Host "Waiting 60s for DC01 to come back online..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "DC01 is back online." -ForegroundColor Green
Wait-ForNext -NextPhase "Phase 3 - Promote DC01"

# =============================================================================
# PHASE 3 - Promote DC01 to Domain Controller
# =============================================================================
Write-PhaseHeader -Phase "PHASE 3" -Title "Promote DC01 to Domain Controller" -VM "DC01"
Invoke-VMScript -VMName "DC01" -ScriptPath "./scripts/phase3-promote-dc.ps1" -Parameters @("DsrmPassword=$adminPassword")

Write-Host ""
Write-Host "Waiting 120s for DC01 to reboot and AD services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 120
Write-Host "DC01 AD services ready." -ForegroundColor Green
Wait-ForNext -NextPhase "Phase 4 - Create AD Structure"

# =============================================================================
# PHASE 4 - Create OUs, Groups and Users
# =============================================================================
Write-PhaseHeader -Phase "PHASE 4" -Title "Create OUs, Security Groups and Users" -VM "DC01"
Invoke-VMScript -VMName "DC01" -ScriptPath "./scripts/phase4-configure-ad.ps1"
Wait-ForNext -NextPhase "Phase 5 - Configure Group Policy"

# =============================================================================
# PHASE 5 - Configure Group Policy
# =============================================================================
Write-PhaseHeader -Phase "PHASE 5" -Title "Configure Group Policy" -VM "DC01"
Invoke-VMScript -VMName "DC01" -ScriptPath "./scripts/phase5-configure-gpo.ps1"
Wait-ForNext -NextPhase "Phase 6 - Verify AD"

# =============================================================================
# PHASE 6 - Verify Active Directory
# =============================================================================
Write-PhaseHeader -Phase "PHASE 6" -Title "Verify Active Directory Configuration" -VM "DC01"
Invoke-VMScript -VMName "DC01" -ScriptPath "./scripts/phase6-verify-ad.ps1"

# =============================================================================
# LAB 2 COMPLETE
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " LAB 2 COMPLETE - Active Directory Configured!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host " Domain: lab.local" -ForegroundColor Cyan
Write-Host " DC01 RDP: $(az vm show -d -g $rg -n DC01 --query publicIps -o tsv)" -ForegroundColor White
Write-Host " Username: azureadmin  |  Password: (stored in Azure Key Vault: vm-admin-password)" -ForegroundColor White
Write-Host ""
Write-Host " Domain Users (Password: P@ssw0rd123!):" -ForegroundColor Cyan
Write-Host "  john.smith  --> GRP_IT" -ForegroundColor White
Write-Host "  sarah.jones --> GRP_Finance" -ForegroundColor White
Write-Host "  mike.brown  --> GRP_Finance" -ForegroundColor White
Write-Host "  lisa.white  --> GRP_HR" -ForegroundColor White
Write-Host "  tom.davis   --> GRP_Sales" -ForegroundColor White
Write-Host ""
Write-Host " Next Step: Deploy Lab 3 - NTFS File Server" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Green
