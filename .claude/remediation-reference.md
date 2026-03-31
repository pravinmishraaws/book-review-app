---
name: remediation-reference
category: Security Best Practices (Azure)
description: A reference library of standard remediation patterns for common Azure security vulnerabilities identified during DevSecOps audits.
---

# Azure Security Remediation Reference Library

This document provides standardized "Good vs. Bad" patterns for Azure environments to ensure consistency in remediation advice.

## 1. Secrets & Identity (Entra ID)
**Goal:** Prevent sensitive data from entering version control and enforce Managed Identities.

| Vulnerability | Insecure Pattern (Bad) | Remediation Pattern (Good) |
| :--- | :--- | :--- |
| **Hardcoded Service Principal** | `client_secret = "h7Q8q..."` | Use **Azure Managed Identity** (System or User Assigned). |
| **Connection Strings** | `Server=tcp:db.windows.net;Password=123` | Store in **Azure Key Vault** and reference via `@Microsoft.KeyVault`. |
| **SAS Tokens** | Long-lived tokens in code. | Use **Stored Access Policies** or User Delegation SAS. |
| **Git History** | Leaked `.env` or `tfstate` secrets. | Use `git-filter-repo` to purge and rotate Azure keys immediately. |

---

## 2. Static Analysis (SAST)
**Goal:** Prevent common code-level injection and logic flaws in Cloud-native apps.

### SQL Injection (Azure SQL / Cosmos DB)
* **Bad:** `context.Database.ExecuteSqlRaw("SELECT * FROM Logs WHERE Level = '" + level + "'")`
* **Good:** `context.Logs.FromSqlInterpolated($"SELECT * FROM Logs WHERE Level = {level}")` (Parameterized)

### Insecure Direct Object Reference (IDOR)
* **Bad:** Fetching a profile using a URL ID without checking `User.Identity`.
* **Good:** Validating that the `oid` (Object ID) in the **Entra ID JWT token** matches the requested resource owner.

### Command Injection (App Service/Functions)
* **Bad:** `os.system("zip " + user_filename)`
* **Good:** Use native language libraries (e.g., Python `zipfile`) to avoid shell execution.

---

## 3. Azure Infrastructure-as-Code (IaC)
**Goal:** Ensure Azure resources follow the **Microsoft Cloud Security Benchmark**.

### Storage Accounts (Terraform `azurerm`)
* **Risk:** Public Blob Access or non-HTTPS traffic allowed.
* **Fix:** ```hcl
    resource "azurerm_storage_account" "example" {
      name                     = "storageswissnorth01"
      resource_group_name      = "dmi-cohort-2-react-app-rg"
      location                 = "switzerlandnorth"
      account_tier             = "Standard"
      account_replication_type = "LRS"

      # Remediation
      allow_nested_items_to_be_public = false
      enable_https_traffic_only       = true
      min_tls_version                 = "TLS1_2"
      shared_access_key_enabled       = false # Force Entra ID auth
    }
    ```

### Network Security Groups (NSG)
* **Risk:** Inbound rule allowing `Any` to port 22/3389.
* **Fix:** Use **Azure Bastion** and set NSG source to `AzureBastionSubnet` or specific admin IP ranges.

### Azure CDN / Front Door
* **Risk:** HTTP allowed or missing WAF (Web Application Firewall).
* **Fix:** Enforce `https_redirect_enabled = true` and attach a WAF Policy.

---

## 4. Software Composition Analysis (SCA)
**Goal:** Maintain a secure supply chain for Azure DevOps/GitHub Actions.

* **Vulnerable Dependency:** Found via `npm audit` or GitHub Dependabot.
* **Azure Context:** Check for vulnerabilities in **Azure Functions** runtimes or **Azure SDKs**.
* **Action:** 1. Update the package: `npm update @azure/storage-blob`.
    2. Pin versions in `package-lock.json` or `requirements.txt`.
    3. Use **Microsoft Defender for Cloud** to scan container images in **Azure Container Registry (ACR)**.

---

## 5. Remediation Workflow for Agent
When a vulnerability is found in the environment:
1.  **Identify** if it's an Identity, Code, or Config issue.
2.  **Reference** this library for the Azure-specific "Good" pattern.
3.  **Draft** the fix using `az` CLI commands or Terraform HCL.
4.  **Propose** the fix with a focus on non-breaking changes (e.g., using `terraform plan` first).