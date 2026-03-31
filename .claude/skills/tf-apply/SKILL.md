---
name: tf-apply
description: Run terraform apply to create or update Azure infrastructure. Use after reviewing a terraform plan.
allowed-tools: Bash, Read
disable-model-invocation: true
---

Run `cd terraform && terraform apply -auto-approve -no-color` and verify the results.

After apply completes:
- [ ] Show the key outputs (CDN Endpoint URL, Storage Account Name, Resource Group)
- [ ] Verify the deployment by checking if the Azure CDN Endpoint provisioning state is "Succeeded"
- [ ] Report the primary web endpoint for the Storage Account
- [ ] Report any errors and suggest fixes

If apply fails, do NOT retry automatically. Show the error and wait for instructions.