# =============================================================================
# Lab 2 - Phase 5: Configure Group Policy
# Runs on: DC01
# =============================================================================
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Import-Module GroupPolicy
Import-Module ActiveDirectory
Write-Host "=== Phase 5: Configuring Group Policy ===" -ForegroundColor Cyan

$gpoName = "Lab - Allow RDP for Domain Users"
$ouPath  = "OU=Lab Computers,DC=lab,DC=local"

New-GPO -Name $gpoName | Out-Null
New-GPLink -Name $gpoName -Target $ouPath
Set-GPRegistryValue -Name $gpoName `
    -Key "HKLM\System\CurrentControlSet\Control\Terminal Server" `
    -ValueName "fDenyTSConnections" `
    -Type DWord `
    -Value 0

Write-Host "  [+] GPO created: $gpoName" -ForegroundColor Green
Write-Host "  [+] Linked to: $ouPath" -ForegroundColor Green

$computer = Get-ADComputer -Filter { Name -eq "CLIENT01" } -ErrorAction SilentlyContinue
if ($computer) {
    $computer | Move-ADObject -TargetPath $ouPath
    Write-Host "  [+] CLIENT01 moved to Lab Computers OU" -ForegroundColor Green
} else {
    Write-Host "  [~] CLIENT01 not yet in AD - will be moved in Lab 3" -ForegroundColor Yellow
}

Write-Host "=== Phase 5 Complete ===" -ForegroundColor Cyan
