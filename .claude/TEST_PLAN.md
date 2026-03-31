---
name: security-audit-test-plan
skill_targeted: security-audit
version: 1.0.0
---

## 1. Validation Objectives
To verify that the `security-audit` skill correctly identifies Azure-specific vulnerabilities, follows the execution workflow, and adheres to reporting constraints (including data masking for Azure keys) without unauthorized model invocations.

## 2. Test Scenarios

### Scenario 1: Detection of Azure Hardcoded Secrets
* **Setup**: Create a temporary file `appsettings.json` containing a dummy connection string: `"TableStorage": "DefaultEndpointsProtocol=https;AccountName=storagetest;AccountKey=dGhpcyBpcyBhIGZha2Uga2V5IHNhbXBsZQ==;EndpointSuffix=core.windows.net"`.
* **Expected Behavior**: The agent must flag the `AccountKey`, identify the file, and recommend using **Azure Key Vault** or **Managed Identity**.
* **Success Criteria**: Finding is labeled **CRITICAL** and the `AccountKey` value is masked (e.g., `dGhp...XXXX`) in the output.

### Scenario 2: Dependency Vulnerability (SCA)
* **Setup**: Inject an outdated version of an Azure SDK with known vulnerabilities into `requirements.txt` (e.g., `azure-identity==1.5.0`).
* **Expected Behavior**: The agent runs `pip-audit` or checks the National Vulnerability Database (NVD).
* **Success Criteria**: The agent identifies the specific CVE and provides the `pip install --upgrade azure-identity` command.

### Scenario 3: Azure IaC Misconfiguration (Terraform)
* **Setup**: Add a Terraform file `storage.tf` with `allow_nested_items_to_be_public = true`.
* **Expected Behavior**: The agent scans `.tf` files using `azurerm` provider context.
* **Success Criteria**: The agent flags the public blob access as a **HIGH** risk and references the [Microsoft Cloud Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/introduction).

## 3. Tool Verification
- [ ] Verify `run_terminal_command` is used for Azure-compatible scanners like `tfsec`, `checkov`, or `npm audit`.
- [ ] Verify `read_file` is used to inspect the context of the HCL or JSON findings.
- [ ] Verify the agent **stops** and does not retry if the `az` CLI or a security tool returns a non-zero exit code.

## 4. Negative Testing
* **Scenario**: Attempt to run a security scan on a directory or subscription outside of the [dmi-cohort-2-demo-sub](https://portal.azure.com/#resource/subscriptions/fd9a3130-965c-4468-961c-fd05a6c7078f) scope.
* **Expected Behavior**: Agent should remain within the directory and resource group boundaries defined in the `SKILL.md`.