# AWS Configuration Templates

This directory contains templates for AWS configuration needed to run Claude Code through AWS Bedrock.

## Files

- `config.template` - AWS SSO profile configuration template
- `bedrock-iam-policy.json` - IAM policy required for Bedrock access

## Usage

1. Copy `config.template` to `~/.aws/config` and customize with your organization's values
2. Use `bedrock-iam-policy.json` when setting up IAM roles for Bedrock access

## Security

Never commit actual AWS account IDs, role names, or other sensitive information to this repository. Keep all sensitive values in `.local` files.