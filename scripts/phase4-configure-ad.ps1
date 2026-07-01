# =============================================================================
# Lab 2 - Phase 4: Create AD OUs, Security Groups and User Accounts
# Runs on: DC01
# =============================================================================
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Import-Module ActiveDirectory
Write-Host "=== Phase 4: Creating AD Structure ===" -ForegroundColor Cyan

$domain   = "lab.local"
$domainDN = "DC=lab,DC=local"
$password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

Write-Host "Creating Organizational Units..." -ForegroundColor Yellow
foreach ($ou in @("Lab Users","Lab Computers","Lab Groups")) {
    New-ADOrganizationalUnit -Name $ou -Path $domainDN -ProtectedFromAccidentalDeletion $false
    Write-Host "  [+] OU: $ou" -ForegroundColor Green
}

Write-Host "Creating Security Groups..." -ForegroundColor Yellow
foreach ($group in @("GRP_Finance","GRP_HR","GRP_Sales","GRP_IT")) {
    New-ADGroup -Name $group -GroupScope Global -GroupCategory Security -Path "OU=Lab Groups,$domainDN"
    Write-Host "  [+] Group: $group" -ForegroundColor Green
}

Write-Host "Creating User Accounts..." -ForegroundColor Yellow
$users = @(
    @{First="John";  Last="Smith"; Username="john.smith";  Group="GRP_IT"     },
    @{First="Sarah"; Last="Jones"; Username="sarah.jones"; Group="GRP_Finance" },
    @{First="Mike";  Last="Brown"; Username="mike.brown";  Group="GRP_Finance" },
    @{First="Lisa";  Last="White"; Username="lisa.white";  Group="GRP_HR"      },
    @{First="Tom";   Last="Davis"; Username="tom.davis";   Group="GRP_Sales"   }
)
foreach ($user in $users) {
    New-ADUser `
        -GivenName $user.First `
        -Surname $user.Last `
        -Name "$($user.First) $($user.Last)" `
        -SamAccountName $user.Username `
        -UserPrincipalName "$($user.Username)@$domain" `
        -Path "OU=Lab Users,$domainDN" `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $true
    Add-ADGroupMember -Identity $user.Group -Members $user.Username
    Write-Host "  [+] $($user.Username) --> $($user.Group)" -ForegroundColor Green
}

Write-Host "=== Phase 4 Complete ===" -ForegroundColor Cyan
