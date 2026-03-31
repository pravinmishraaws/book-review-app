---
name: security-audit
description: Professional-grade security auditing for Azure-based source code, dependencies, and IaC. Identifies vulnerabilities, detects Azure secrets, and provides remediation strategies aligned with Microsoft Cloud Security Benchmark (MCSB) and OWASP.
allowed-tools: [read_file, list_files, search_files, run_terminal_command]
disable-model-invocation: false
---

## 1. Audit Objectives
The agent must verify the following areas and check off items as they are completed:

- [ ] **Static Analysis (SAST):** Detecting patterns of insecure code (e.g., `SQL injection`, `XSS`, `Insecure Direct Object References`).
- [ ] **Secret Detection:** Identifying hardcoded Azure Service Principal keys, Connection Strings, SAS Tokens, and Management Certificates.
- [ ] **SCA (Software Composition Analysis):** Checking for CVEs in `npm`, `pip`, or `go` dependencies.
- [ ] **Azure IaC Auditing:** Scanning Terraform (`azurerm`), Bicep, or ARM templates for misconfigurations (e.g., Public Blob Access, missing HTTPS-only on CDN).


## 2. Execution Workflow

### Preparation Phase
- [ ] **Clone Repository:** Use `git clone --depth 1` for speed.
- [ ] **Environment Setup:** Initialize virtual environments or install read-only dependencies to allow static analyzers to resolve imports.
- [ ] **Identify Azure Scope:** Confirm target Resource Group (e.g., `dmi-cohort-2-react-app-rg`) and subscription.

### Phase A: Discovery
- [ ] Identify primary language(s) and framework(s).
- [ ] Locate dependency manifests (e.g., `package-lock.json`, `requirements.txt`).
- [ ] Identify Azure Infrastructure-as-Code files (e.g., `.tf`, `.bicep`, `azure-pipelines.yml`).

### Phase B: Analysis & Tooling
- [ ] **Run SAST:** Execute relevant linters (e.g., `Bandit` for Python, `ESLint-plugin-security` for JS).
- [ ] **Azure Secret Scan:** Search for high-entropy strings and Azure patterns (e.g., `AccountKey=`, `AZURE_CLIENT_SECRET`, `Endpoint=sb://`).
- [ ] **Run SCA:** Execute dependency audits (e.g., `npm audit`, `pip-audit`).
- [ ] **Azure IaC Check:** Use tools like `tfsec` or `checkov` specifically targeting Azure resource types.
- [ ] **Logic Audit:** Review Azure AD (Entra ID) integration points and RBAC assignments for "Owner" over-privilege.


## 3. Reporting Standard
Findings must be reported in a structured format:
- **Severity:** [Critical/High/Medium/Low]
- **Vulnerability:** Short name of the issue.
- **Location:** File path and line number.
- **Azure Context:** (Optional) Impact on Azure resources (e.g., "Exposes Storage Account in Switzerland North").
- **Remediation:** Specific code change or `az` CLI command to fix the issue.


## 4. Constraints
- **No Auto-Retry:** If a security tool fails, **STOP**. Do not retry automatically.
- **Data Masking:** Never output full discovered secrets (especially SAS tokens) in logs. Use `AZ...XXXX` masking.
- **Compliance:** Align suggestions with the **Microsoft Cloud Security Benchmark**.