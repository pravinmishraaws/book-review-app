#!/bin/bash
# MULTI-CLOUD GUARD hook — blocks dangerous infrastructure commands

# Read the MCP tool input
INPUT=$(cat)
# Extract the command string
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Define high-risk patterns
# Terraform: Destroying or auto-approving changes
TF_DANGER="terraform destroy|terraform apply.*-auto-approve"

# AWS: Deleting buckets, objects, or recursive removals
AWS_DANGER="aws s3 (rm|rb).*--recursive|aws (ec2|rds|lambda) delete-.*"

# Azure: Deleting resource groups, resources, or storage containers
AZ_DANGER="az (group|resource|storage container|vm) delete|az role assignment delete"

# Combine patterns and check
if echo "$CMD" | grep -qE "($TF_DANGER|$AWS_DANGER|$AZ_DANGER)"; then
  echo '{
    "decision": "block", 
    "reason": "Destructive multi-cloud command detected. Manual review or specialized sub-agents required for infrastructure removal."
  }'
fi