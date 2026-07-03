# =============================================================================
# Lab 2 - Phase 3: Promote DC01 to Domain Controller
# Runs on: DC01
#
# SECURITY: The DSRM (Safe Mode) password is NOT stored in this script.
# It is retrieved from Azure Key Vault by run-lab2.ps1 and passed in
# as a parameter at execution time.
# =============================================================================
param(
    [Parameter(Mandatory = $true)]
    [string]$DsrmPassword
)

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Write-Host "=== Phase 3: Promoting DC01 to Domain Controller ===" -ForegroundColor Cyan
$safeModePassword = ConvertTo-SecureString $DsrmPassword -AsPlainText -Force
Import-Module ADDSDeployment -Force
Install-ADDSForest `
    -DomainName "lab.local" `
    -DomainNetbiosName "LAB" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $safeModePassword `
    -Force:$true `
    -NoRebootOnCompletion:$false
Write-Host "=== Phase 3 Complete ===" -ForegroundColor Cyan
