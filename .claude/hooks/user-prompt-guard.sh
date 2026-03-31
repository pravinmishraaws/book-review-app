#!/bin/bash
# MULTI-CLOUD PROMPT GUARD — catches destructive intent in user prompts

# Read the input provided by the MCP hook
INPUT=$(cat)
# Extract the user's natural language prompt
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Define patterns for destructive natural language
# Covers Terraform, General CLI, and Cloud-specific "cleanup" slang
TERRAFORM_INTENT="delete all|destroy everything|teardown|remove all resources"
AWS_INTENT="nuke the account|wipe the s3|drop the tables|terminate all"
AZURE_INTENT="wipe the subscription|delete the resource group|drop the tenant|clear the rg"

# Combine patterns (case-insensitive)
if echo "$PROMPT" | grep -iqE "($TERRAFORM_INTENT|$AWS_INTENT|$AZURE_INTENT|nuke|wipe)"; then
  echo '{
    "decision": "block", 
    "reason": "High-risk intent detected. To remove infrastructure, please provide specific resource names or use controlled teardown workflows (/tf-destroy)."
  }'
fi