# Security Architecture

## Token Isolation Principle

This action implements a **zero-trust token isolation model** where each repository maintains complete independence:

- Each repository uses its own PAT with access ONLY to itself
- No cross-repository permissions required
- Complete security isolation between repositories
- Public action code with private runtime secrets

## Why This Works

### Public Actions = No Authentication Required

Since `atxtechbro/dotfiles` is a public repository:

1. **Action Reference**: Any repository (public or private) can reference our public actions and workflows just like they reference `actions/checkout@v4`
2. **Runtime Secrets**: Secrets are provided by the calling repository at runtime, not stored in the action
3. **Execution Context**: The workflow executes entirely in the calling repository's security context
4. **Token Scope**: The PAT only needs permissions for the repository it's used in

### Security Benefits

- **Blast Radius Limitation**: A compromised token affects only one repository
- **Principle of Least Privilege**: Each token has minimum necessary permissions
- **No Token Sharing**: Each repository manages its own secrets
- **Audit Isolation**: Security events are isolated per repository

## Token Setup Guide

### Option 1: Fine-Grained PAT (Recommended)

Fine-grained personal access tokens provide the highest security with repository-specific scoping.

#### Steps:
1. Navigate to: GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Click "Generate new token"
3. Token settings:
   - **Expiration**: Set based on your security policy
   - **Repository access**: Select **only** the specific repository
   - **Permissions**:
     ```
     Repository permissions:
     - Actions: Write (if Claude needs to modify workflows)
     - Contents: Write
     - Issues: Write  
     - Metadata: Read (automatically selected)
     - Pull requests: Write
     ```
4. Name convention: `CLAUDE_TRIGGER_PAT_[REPOSITORY_NAME]`
5. Generate and copy the token
6. Add to repository: Settings → Secrets and variables → Actions → New repository secret

### Option 2: Classic PAT (Broader Access)

Classic tokens work but provide broader access than necessary.

#### Required Scopes:
- `repo` (Full control of private repositories)
- `workflow` (Update GitHub Action workflows)

⚠️ **Warning**: Classic PATs with `repo` scope have access to ALL your repositories. Use fine-grained tokens when possible.

## Implementation Examples

### Private Repository Setup

```yaml
# .github/workflows/auto-trigger-claude.yml
name: Auto-Trigger Claude
on:
  issues:
    types: [opened]

jobs:
  auto-trigger-claude:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    
    steps:
      - name: Auto-trigger Claude
        uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
        with:
          github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}  # Repo-specific PAT
          allowed-users: 'your-username'
```

### Multiple Repository Management

If managing multiple repositories:

1. Create a separate fine-grained PAT for each repository
2. Name them distinctly: 
   - `CLAUDE_TRIGGER_PAT_REPO1`
   - `CLAUDE_TRIGGER_PAT_REPO2`
3. Each repository uses only its own PAT
4. No cross-contamination possible

## Security Checklist

### For Repository Administrators

- [ ] Use fine-grained PATs instead of classic PATs
- [ ] Scope PAT to single repository only
- [ ] Set appropriate token expiration
- [ ] Regularly rotate tokens
- [ ] Audit token usage in Settings → Personal access tokens
- [ ] Never commit tokens to code
- [ ] Use repository secrets for token storage

### For Action Users

- [ ] Verify action source is from trusted repository
- [ ] Review action code before implementation
- [ ] Understand what permissions are required and why
- [ ] Monitor GitHub Actions logs for unexpected behavior
- [ ] Set up GitHub security alerts for your repository

## Threat Model

### What This Protects Against

1. **Token Compromise**: If one repository's token is exposed, other repositories remain secure
2. **Lateral Movement**: Attackers cannot move between repositories via shared tokens
3. **Over-Permissioning**: Tokens have minimal required permissions
4. **Supply Chain**: Public action code is auditable by community

### What This Doesn't Protect Against

1. **Malicious Action Updates**: Always pin to specific commits/tags for production
2. **Account Compromise**: Use 2FA and secure your GitHub account
3. **Insider Threats**: Authorized users with malicious intent
4. **Zero-Days**: Unknown vulnerabilities in GitHub Actions platform

## Incident Response

If you suspect token compromise:

1. **Immediately revoke** the affected PAT in GitHub Settings
2. **Generate new PAT** with same permissions
3. **Update repository secret** with new token
4. **Audit recent activities** in repository's Security tab
5. **Review Action logs** for unauthorized usage

## Questions or Concerns?

For security questions about this action, please:
- Review the public source code in this repository
- Open an issue for clarification (do not include sensitive information)
- For private security concerns, use GitHub's private vulnerability reporting

---

*This security model ensures that using these public GitHub Actions maintains the privacy and security of your private repositories.*