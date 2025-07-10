# Claude Code AWS Bedrock Setup Guide

This guide helps you configure Claude Code to run through AWS Bedrock, enabling enterprise users to leverage corporate AWS accounts with proper IAM controls and cost tracking.

## Prerequisites

Before setting up Bedrock integration, ensure you have:

1. **AWS Account with Bedrock Access**
   - Access enabled in your AWS account
   - Appropriate IAM permissions (see IAM Configuration below)

2. **Claude Model Access**
   - Access to desired Claude models (e.g., Claude Sonnet 4) in Bedrock
   - Navigate to Amazon Bedrock console → Model access → Request access
   - Wait for approval (usually instant for most regions)

3. **AWS CLI Installed**
   - Download from: https://aws.amazon.com/cli/
   - Verify installation: `aws --version`

4. **Claude Code Installed**
   - Install via npm: `npm install -g @anthropic-ai/claude-code`
   - Or use the dotfiles setup: `source setup.sh`

## Quick Start

1. **Run the automated setup**:
   ```bash
   source setup.sh
   # Answer 'y' when prompted for Bedrock setup
   ```

   Or run directly:
   ```bash
   bash ~/ppv/pillars/dotfiles/utils/setup-bedrock-claude.sh
   ```

2. **Configure your AWS profile**:
   Edit `~/.aws/config` with your organization's SSO details:
   ```ini
   [profile bedrock_profile]
   sso_start_url  = https://your-org.awsapps.com/start
   sso_region     = us-east-1
   sso_account_id = YOUR_ACCOUNT_ID
   sso_role_name  = YOUR_ROLE_NAME
   region         = us-east-1
   ```

3. **Configure Bedrock environment**:
   Edit `~/.bash_exports.bedrock.local`:
   ```bash
   export AWS_PROFILE=bedrock_profile
   export ANTHROPIC_MODEL='us.anthropic.claude-3-7-sonnet-20250219-v1:0'
   # Or use your organization's specific ARNs
   ```

4. **Login to AWS SSO**:
   ```bash
   aws sso login --profile bedrock_profile
   ```

5. **Run Claude Code with Bedrock**:
   ```bash
   source ~/.bashrc  # Load the environment
   claude-bedrock    # Run with automatic SSO check
   ```

## Manual Setup

If you prefer manual configuration:

### 1. AWS Configuration

Create or update `~/.aws/config`:
```ini
[profile bedrock_profile]
sso_start_url  = https://your-org.awsapps.com/start
sso_region     = us-east-1
sso_account_id = YOUR_ACCOUNT_ID
sso_role_name  = YOUR_ROLE_NAME
region         = us-east-1
cli_pager      =
```

### 2. Environment Variables

Create `~/.bash_exports.bedrock.local`:
```bash
#!/bin/bash
# Enable Bedrock integration
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=bedrock_profile

# Model configuration
export ANTHROPIC_MODEL='us.anthropic.claude-3-7-sonnet-20250219-v1:0'
export ANTHROPIC_SMALL_FAST_MODEL='us.anthropic.claude-3-5-haiku-20241022-v1:0'
```

### 3. Update .bashrc

Add to your `~/.bashrc`:
```bash
# Source Bedrock exports if available
[[ -f ~/.bash_exports.bedrock.local ]] && source ~/.bash_exports.bedrock.local
```

## IAM Configuration

Your IAM role needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*"
      ]
    }
  ]
}
```

## Usage

### Basic Usage

```bash
# Run with Bedrock (checks SSO automatically)
claude-bedrock

# Or set environment and run standard claude
source ~/.bash_exports.bedrock.local
claude
```

### Multiple AWS Profiles

Add multiple profiles to `~/.aws/config`:
```ini
[profile bedrock_dev]
sso_start_url  = https://your-org.awsapps.com/start
sso_account_id = DEV_ACCOUNT_ID
# ...

[profile bedrock_prod]
sso_start_url  = https://your-org.awsapps.com/start
sso_account_id = PROD_ACCOUNT_ID
# ...
```

Switch between them:
```bash
export AWS_PROFILE=bedrock_dev
claude-bedrock
```

### Using Specific Models

```bash
# Via environment variable
export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-20250514-v1:0'
claude-bedrock

# Or use inference profile ARNs
export ANTHROPIC_MODEL='arn:aws:bedrock:us-east-1:123456789:inference-profile/your-profile'
```

## Troubleshooting

### SSO Login Issues

```bash
# Check current identity
aws sts get-caller-identity --profile bedrock_profile

# Force new login
aws sso logout --profile bedrock_profile
aws sso login --profile bedrock_profile
```

### Region Issues

```bash
# Check model availability
aws bedrock list-inference-profiles --region your-region

# Override region for specific model
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
```

### Environment Not Loading

```bash
# Verify exports are loaded
echo $CLAUDE_CODE_USE_BEDROCK  # Should output: 1
echo $AWS_PROFILE               # Should output: bedrock_profile

# Reload environment
source ~/.bashrc
```

### Model Access Errors

If you receive "on-demand throughput isn't supported":
- Ensure you're using an inference profile ID, not a model ID
- Check model access in Bedrock console
- Verify your IAM permissions

## Security Best Practices

1. **Never commit sensitive data**:
   - Keep AWS account IDs in `.local` files
   - Use `.gitignore` for `*.local` files

2. **Use SSO instead of long-lived credentials**:
   - Temporary credentials auto-expire
   - Centrally managed access

3. **Restrict IAM permissions**:
   - Use least-privilege principle
   - Limit to specific inference profiles if possible

4. **Separate AWS accounts**:
   - Consider dedicated account for AI workloads
   - Simplifies cost tracking and access control

## Additional Resources

- [Claude Code on Amazon Bedrock docs](https://docs.anthropic.com/en/docs/claude-code/deployment/amazon-bedrock)
- [AWS Bedrock documentation](https://docs.aws.amazon.com/bedrock/)
- [AWS Bedrock pricing](https://aws.amazon.com/bedrock/pricing/)
- [AWS SSO configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)