# =============================================================================
# Lab 2 - Phase 1: Verify Lab 1 Infrastructure
# Runs locally on your Mac
# =============================================================================
param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "RG-FileServerLab"
)

Write-Host "=== Phase 1: Verifying Lab 1 Infrastructure ===" -ForegroundColor Cyan
$pass = $true

foreach ($vm in @("DC01", "FS01", "CLIENT01")) {
    $state = az vm show -d --resource-group $ResourceGroup --name $vm --query "powerState" -o tsv 2>$null
    if ($state -eq "VM running") {
        Write-Host "  [PASS] $vm is running" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $vm state: $state" -ForegroundColor Red
        $pass = $false
    }
}

Write-Host ""
Write-Host "  VM Public IPs:" -ForegroundColor Yellow
Write-Host "  DC01     - $(az vm show -d -g $ResourceGroup -n DC01 --query publicIps -o tsv)" -ForegroundColor White
Write-Host "  FS01     - $(az vm show -d -g $ResourceGroup -n FS01 --query publicIps -o tsv)" -ForegroundColor White
Write-Host "  CLIENT01 - $(az vm show -d -g $ResourceGroup -n CLIENT01 --query publicIps -o tsv)" -ForegroundColor White

if ($pass) { Write-Host "=== Phase 1 PASSED ===" -ForegroundColor Green }
else { Write-Host "=== Phase 1 FAILED - Deploy Lab 1 first ===" -ForegroundColor Red; exit 1 }
