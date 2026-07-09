# Lab 2: Active Directory Domain Services

![PowerShell](https://img.shields.io/badge/PowerShell-Automation-5391FE?logo=powershell)
![Windows Server](https://img.shields.io/badge/Windows_Server-2025-0078D6?logo=windows)
![Active Directory](https://img.shields.io/badge/Active_Directory-Domain_Services-0078D6?logo=microsoft)


## 🎥 Lab Demo

*Watch the full lab walkthrough (7 min):*


https://github.com/user-attachments/assets/90dff840-f5c9-4c78-82c9-ad3e29d852af


## Overview

This is the second lab in a three-part series. Building on the Azure infrastructure deployed in Lab 1, I configure a fully functional **Active Directory Domain Services** environment on Windows Server 2025.

I perform all configuration through a phased PowerShell automation approach I built using Azure VM Run Commands — keeping OS-level configuration completely separate from the Terraform infrastructure provisioning I did in Lab 1.

---

## Lab Series

| Lab | Title | Skills |
|-----|-------|--------|
| [Lab 1](https://github.com/kingsrule50/ntfs-lab-terraform) | Azure Infrastructure with Terraform | Terraform, Azure Networking, IaC |
| **Lab 2** (this repo) | Active Directory Domain Services | Windows Server, AD DS, GPO, PowerShell |
| [Lab 3](https://github.com/kingsrule50/ntfs-lab-fileserver) | NTFS File Server and Access Control | SMB, NTFS, RBAC, Access Control |

---

## Architecture

![Lab Architecture](screenshots/00-architecture.png)
*In this lab I execute Phases 2–3 of the series architecture — AD DS installation, DC promotion, AD object creation, and Group Policy.*

---

## What I Configure

### Domain
- Domain: `lab.local`
- NetBIOS: `LAB`
- Domain Controller: `DC01` (`10.0.1.5`)

### Organizational Units
| OU | Purpose |
|----|---------|
| Lab Users | All domain user accounts |
| Lab Groups | All security groups |
| Lab Computers | Domain-joined workstations |

### Security Groups
| Group | Scope | Purpose |
|-------|-------|---------|
| GRP_Finance | Global Security | Finance department access |
| GRP_HR | Global Security | HR department access |
| GRP_Sales | Global Security | Sales department access |
| GRP_IT | Global Security | IT full control access |

### User Accounts
| Username | Full Name | Group |
|----------|-----------|-------|
| john.smith | John Smith | GRP_IT |
| sarah.jones | Sarah Jones | GRP_Finance |
| mike.brown | Mike Brown | GRP_Finance |
| lisa.white | Lisa White | GRP_HR |
| tom.davis | Tom Davis | GRP_Sales |

### Group Policy
| GPO | Linked To | Setting |
|-----|-----------|---------|
| Lab - Allow RDP for Domain Users | Lab Computers OU | fDenyTSConnections = 0 |

---

## Phased Deployment Approach

I designed this lab around the phased deployment pattern to avoid the timing and state issues I encountered when mixing infrastructure provisioning with OS-level configuration.

```
Phase 1 - Verify Lab 1 infrastructure is running
Phase 2 - Install AD DS feature on DC01
          [DC01 reboots]
Phase 3 - Promote DC01 to Domain Controller
          [DC01 reboots, AD initializes]
Phase 4 - Create OUs, Security Groups and User Accounts
Phase 5 - Configure Group Policy
Phase 6 - Verify Active Directory configuration
```

---

## Prerequisites

- **Lab 1 must be deployed first** — [ntfs-lab-terraform](https://github.com/kingsrule50/ntfs-lab-terraform)
- Azure CLI installed and authenticated (`az login`)
- PowerShell 7+ installed on your machine

---

## Usage

**Step 1 — Navigate to the repo:**
```powershell
cd /path/to/ntfs-lab-ad
```

**Step 2 — Run the lab:**
```powershell
./run-lab2.ps1
```

![Key Vault credential retrieval](screenshots/01-keyvault-credentials.png)
*My orchestration script retrieves the admin credentials from Azure Key Vault at runtime before promoting DC01 — I never store passwords in code or pass them on the command line.*

I built the script to pause between each phase and wait for you to press **Enter** before proceeding, so you can verify each phase completed successfully before moving to the next.

**Step 3 — Proceed to Lab 3:**
Once verification passes, proceed to [Lab 3 - NTFS File Server](https://github.com/kingsrule50/ntfs-lab-fileserver).

---

## Credentials

| Account | Username | Source |
|---------|----------|--------|
| Local Admin | azureadmin | Retrieved from Azure Key Vault (`vm-admin-password`) |
| DSRM | (recovery) | Generated at promotion time |
| Domain Users | see table above | Set during provisioning; rotate after first logon |

I never commit passwords to this repository — my orchestration script pulls credentials from Key Vault at runtime.

---

## File Structure

```
ntfs-lab-ad/
├── run-lab2.ps1                    # Master orchestration script
└── scripts/
    ├── phase1-verify-infra.ps1     # Verify Lab 1 VMs are running
    ├── phase2-install-adds.ps1     # Install AD DS Windows feature
    ├── phase3-promote-dc.ps1       # Promote DC01 to Domain Controller
    ├── phase4-configure-ad.ps1     # Create OUs, Groups, Users
    ├── phase5-configure-gpo.ps1    # Configure Group Policy
    └── phase6-verify-ad.ps1        # Verify all AD objects
```

---

## Expected Verification Output

```
=== Phase 6: Active Directory Verification ===
  [PASS] OU: Lab Users
  [PASS] OU: Lab Groups
  [PASS] OU: Lab Computers
  [PASS] Group: GRP_Finance
  [PASS] Group: GRP_HR
  [PASS] Group: GRP_Sales
  [PASS] Group: GRP_IT
  [PASS] john.smith --> GRP_IT
  [PASS] sarah.jones --> GRP_Finance
  [PASS] mike.brown --> GRP_Finance
  [PASS] lisa.white --> GRP_HR
  [PASS] tom.davis --> GRP_Sales
=== Lab 2 Verification PASSED ===
```

---

## Configuration Results

**OUs, security groups, and users created in `lab.local`:**

![ADUC](screenshots/02-aduc-ous-groups-users.png)
*Active Directory Users and Computers on DC01 — the four department groups under the Lab Groups OU, with group membership matching the RBAC design (e.g., Mike Brown and Sarah Jones in GRP_Finance, John Smith in GRP_IT).*

**Group Policy configured and linked:**

![GPO](screenshots/03-gpo-rdp-policy.png)
*The `Lab - Allow RDP for Domain Users` GPO linked to the Lab Computers OU in Group Policy Management.*

---

## Skills Demonstrated

- Windows Server 2025 administration
- Active Directory Domain Services installation and promotion
- Organizational Unit design and creation
- Security group strategy (department-based RBAC)
- User account provisioning via PowerShell
- Group Policy Object creation and linking
- PowerShell automation with Azure VM Run Commands
- Phased deployment methodology

---

## Author

**Chinedu Asuzu** | Cloud Security Engineer  
[GitHub](https://github.com/kingsrule50) | [LinkedIn](https://linkedin.com/in/chineduasuzu)  
Certifications: CISA | CompTIA Security+ | Microsoft SC-401
