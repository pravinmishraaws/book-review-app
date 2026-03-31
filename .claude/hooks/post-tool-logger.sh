#!/bin/bash
# MULTI-CLOUD LOG hook — records infrastructure changes to the deploy log

# Read the input provided by the MCP hook
INPUT=$(cat)
# Extract the command being executed from the JSON input
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Define patterns that represent "Write" or "Deploy" actions
TF_PATTERN="terraform apply"
AWS_PATTERN="aws (s3|ec2|lambda|cloudfront|iam|dynamodb) (create|put|update|delete|copy|sync)"
AZ_PATTERN="az (group|vm|storage|network|resource|role) (create|update|delete|assignment)"

# Current timestamp in ISO 8601
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Log Terraform executions
if echo "$CMD" | grep -q "$TF_PATTERN"; then
  echo "[$TIMESTAMP] [TERRAFORM] Execute: $CMD" >> .claude/deploy.log
fi

# Log AWS CLI destructive or creation actions
if echo "$CMD" | grep -E -q "$AWS_PATTERN"; then
  echo "[$TIMESTAMP] [AWS-CLI] Execute: $CMD" >> .claude/deploy.log
fi

# Log Azure CLI destructive or creation actions
if echo "$CMD" | grep -E -q "$AZ_PATTERN"; then
  echo "[$TIMESTAMP] [AZURE-CLI] Execute: $CMD" >> .claude/deploy.log
fi