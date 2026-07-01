# =============================================================================
# Lab 2 - Phase 2: Install AD DS Feature
# Runs on: DC01
# =============================================================================
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Write-Host "=== Phase 2: Installing AD DS Feature ===" -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose:$false
Write-Host "AD DS feature installed successfully." -ForegroundColor Green
Write-Host "=== Phase 2 Complete ===" -ForegroundColor Cyan
