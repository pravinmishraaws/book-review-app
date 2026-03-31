---
name: tf-plan
description: Run terraform plan and analyze the output for Azure infrastructure risks. Use before applying any changes to the Resource Group.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

Run `cd terraform && terraform plan -no-color` and analyze the output.

Summarize:
- [ ] **Resource Count**: Total resources to be added, changed, or destroyed.
- [ ] **Critical Changes**: Identify any "Force New" attributes that will cause resource recreation (e.g., changing a Storage Account name or location).
- [ ] **Security Impact**: Highlight changes to Network Security Groups (NSGs), CDN HTTPS settings, or Role Assignments (RBAC).
- [ ] **Estimated Blast Radius**: Assessment of impact on the environment.

If the plan fails, diagnose the error (e.g., authentication issues with `az login` or naming conflicts) and suggest a fix.