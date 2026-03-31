---
name: deploy
description: Sync site files to Azure Storage and purge Azure CDN cache. Use after terraform apply to push site content live.
allowed-tools: Bash, Read
disable-model-invocation: true
---

Deploy site files to Azure Storage and purge Azure CDN cache.

Steps:
- [ ] Get terraform outputs: `cd terraform && terraform output -json`
- [ ] Sync site files: `az storage blob upload-batch --account-name <storage_account_name> --auth-mode key -d '$web' -s . --exclude-path "terraform/*;*.md;.git/*;.github/*;.claude/*;.cursor/*;.mcp.json" --overwrite`
- [ ] Purge CDN cache: `az cdn endpoint purge -g <resource_group> -n <endpoint_name> --profile-name <profile_name> --content-paths "/*"`
- [ ] Report the Website URL and purge status

If any step fails, stop and report the error. Do not continue to the next step.