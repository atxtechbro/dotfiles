# Auto Trigger Claude Action

A reusable composite GitHub Action that automatically triggers Claude to implement issues when they're created. This action is designed to be used across multiple repositories without duplication.

## Features

- ✅ **User Authorization**: Only allows specified users to trigger Claude
- 🔧 **Configurable**: Customize PR templates, messages, and allowed users per repository
- 🔒 **Secure**: Requires explicit token passing, no hardcoded secrets
- 📦 **Reusable**: Use across all your repositories without copying workflow files

## Usage

### Basic Usage (in your repository)

Create `.github/workflows/auto-trigger-claude.yml` in your repository:

```yaml
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
          github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}
          allowed-users: 'atxtechbro'  # Your GitHub username
```

### Advanced Usage

```yaml
- name: Auto-trigger Claude
  uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
  with:
    github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}
    allowed-users: 'atxtechbro,trusted-contributor,another-user'
    pr-template-url: 'https://github.com/myorg/myrepo/blob/main/.github/PULL_REQUEST_TEMPLATE.md'
    custom-message: |
      Additional context for this repository:
      - Follow our coding standards at /docs/standards.md
      - Run tests with `npm test` before creating PR
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `github-token` | GitHub token with permissions to comment on issues | Yes | - |
| `allowed-users` | Comma-separated list of GitHub usernames allowed to trigger Claude | No | `atxtechbro` |
| `pr-template-url` | URL to the PR template Claude should use | No | Auto-detects from repository |
| `custom-message` | Custom message to append to the Claude trigger comment | No | Empty |
| `issue-number` | Issue number to comment on | No | Current issue |
| `repository` | Repository in owner/repo format | No | Current repository |

## Required Secrets

Each repository using this action needs to configure:

1. **`CLAUDE_TRIGGER_PAT`**: A GitHub Personal Access Token with repository and workflow permissions
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Create a token with the following scopes:
     - `repo` (full control of private repositories)
     - `workflow` (update GitHub Action workflows - required if Claude needs to modify .github/workflows files)
   - Add it to your repository secrets

2. **`CLAUDE_CODE_OAUTH_TOKEN`**: Required if using claude-implementation workflow
   - Obtained from Claude Code setup
   - Add to repository secrets for Claude to create PRs

## Security

- **User Authorization**: Only users listed in `allowed-users` can trigger Claude
- **No Hardcoded Secrets**: All tokens must be explicitly passed from the calling workflow
- **Graceful Failures**: Unauthorized attempts exit gracefully without errors

## Examples

### Multiple Authorized Users

```yaml
- uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
  with:
    github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}
    allowed-users: 'atxtechbro,teammate1,teammate2'
```

### Custom PR Template per Repository

```yaml
- uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
  with:
    github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}
    pr-template-url: 'https://github.com/myorg/templates/blob/main/PR_TEMPLATE.md'
```

### With Repository-Specific Instructions

```yaml
- uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
  with:
    github-token: ${{ secrets.CLAUDE_TRIGGER_PAT }}
    custom-message: |
      This is a Python repository. Please:
      - Use Black for formatting
      - Include type hints
      - Add unit tests for new functions
```

## Versioning

For stability, you can pin to a specific commit or tag:

```yaml
# Pin to specific commit
uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@38c7caa

# Pin to tag (when available)
uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@v1.0.0

# Always use latest from main branch
uses: atxtechbro/dotfiles/.github/actions/auto-trigger-claude@main
```

## Troubleshooting

### Claude not triggering

1. Check that the user creating the issue is in `allowed-users`
2. Verify `CLAUDE_TRIGGER_PAT` secret is set in repository settings
3. Check workflow runs for authorization messages

### Permission errors

Ensure your PAT has the required scopes:
- `repo` (full control of private repositories)
- Or at minimum: `public_repo` and `issues` for public repositories

## License

Part of the atxtechbro/dotfiles repository. See repository license for details.