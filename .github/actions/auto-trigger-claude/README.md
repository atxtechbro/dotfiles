# Auto Trigger Claude Action

A reusable composite GitHub Action that automatically triggers Claude to implement issues when they're created. This action enables **Ultimate OSE (Outside and Slightly Elevated)** automation where GitHub issues automatically trigger Claude to implement and create PRs with zero manual intervention.

## Overview

This action is the cornerstone of autonomous issue resolution - transforming GitHub issues into implemented pull requests without human intervention. It embodies the principle of managing AI agents at scale rather than manual coding.

### Business Value
- **Zero-touch automation**: Issues become PRs automatically
- **Ultimate OSE**: Operate at the management level, not implementation level
- **Compound improvements**: Each automated issue adds to organizational knowledge
- **Audit trail**: Complete visibility of automated work

## When to Use This vs Alternatives

### Use Auto-Trigger Workflow When:
- Issue requires implementation work
- You want zero manual intervention 
- Following Ultimate OSE principles (manage agents, not code)
- Need audit trail of automated work
- Issues are well-defined and scoped
- Working across multiple repositories

### Use `/close-issue` Command When:
- Working locally with Claude Code CLI
- Need interactive discussion during implementation
- Prefer manual control over PR creation
- Issue is complex and needs human oversight
- Want to provide real-time guidance to Claude
- Testing or debugging implementations

## How It Works

### The Automation Flow
1. **Issue created** on GitHub (by authorized user)
2. **Workflow triggers** via `.github/workflows/auto-trigger-claude.yml`
3. **Security check** verifies user is authorized
4. **Claude receives instruction** to implement the issue
5. **Implementation happens** via `anthropics/claude-code-action@beta`
6. **PR created automatically** with `claude/` branch prefix

### The Secret Sauce
The `anthropics/claude-code-action@beta` GitHub Action has built-in PR creation capability:
- Claude focuses purely on implementation
- The Action handles all git operations
- Branches are created with `claude/` prefix automatically
- PR is created when implementation is complete
- No manual PR creation tools needed - simpler and more reliable

## Features

- ✅ **User Authorization**: Only allows specified users to trigger Claude
- 🔧 **Configurable**: Customize PR templates, messages, and allowed users per repository
- 🔒 **Secure**: Requires explicit token passing, no hardcoded secrets
- 📦 **Reusable**: Use across all your repositories without copying workflow files
- 🚀 **Automated**: Zero manual intervention from issue to PR

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

## Configuration Reference

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `github-token` | GitHub token with permissions to comment on issues | Yes | - |
| `allowed-users` | Comma-separated list of GitHub usernames allowed to trigger Claude | No | `atxtechbro` |
| `pr-template-url` | URL to the PR template Claude should use | No | Auto-detects from repository |
| `custom-message` | Custom message to append to the Claude trigger comment | No | Empty |
| `issue-number` | Issue number to comment on | No | Current issue |
| `repository` | Repository in owner/repo format | No | Current repository |

### Required Secrets

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

## Implementation Details

### Related Workflows
- **Trigger**: `.github/workflows/auto-trigger-claude.yml` - Initiates the process
- **Implementation**: `.github/workflows/claude-implementation.yml` - Claude's execution environment
- **Local alternative**: `/close-issue` command in Claude Code CLI

### Principles Applied
- **systems-stewardship**: Single source of truth for Claude automation
- **ose (Outside and Slightly Elevated)**: Manage agents at scale, not individual implementations
- **snowball-method**: Each automated issue adds to compound knowledge
- **subtraction-creates-value**: Removes manual PR creation complexity

### Security Model
- User authorization happens at workflow level
- Tokens are never hardcoded, always passed as secrets
- Unauthorized users fail gracefully without errors
- Complete audit trail in GitHub Actions logs

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
4. Ensure the workflow file exists in `.github/workflows/`

### Permission errors

Ensure your PAT has the required scopes:
- `repo` (full control of private repositories)
- `workflow` (for modifying GitHub Actions workflows)
- Or at minimum: `public_repo` and `issues` for public repositories

### PR not being created

- Check that `CLAUDE_CODE_OAUTH_TOKEN` is set in repository secrets
- Verify Claude implementation completed successfully in Actions logs
- Ensure the issue description is clear and implementable

## License

Part of the atxtechbro/dotfiles repository. See repository license for details.