# =============================================================================
# Lab 2 - Phase 3: Promote DC01 to Domain Controller
# Runs on: DC01
# =============================================================================
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Write-Host "=== Phase 3: Promoting DC01 to Domain Controller ===" -ForegroundColor Cyan
$safeModePassword = ConvertTo-SecureString "Dsrm@Lab2026!" -AsPlainText -Force
Import-Module ADDSDeployment -Force
Install-ADDSForest `
    -DomainName "lab.local" `
    -DomainNetbiosName "LAB" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $safeModePassword `
    -Force:$true `
    -NoRebootOnCompletion:$false
Write-Host "=== Phase 3 Complete ===" -ForegroundColor Cyan
