# Claude GitHub Workflows

This repository contains two GitHub Actions workflows for Claude integration, each serving a different purpose.

## Workflows Overview

### 1. Claude Code Assistant (`claude-code-assistant.yml`)
- **Purpose**: Dual-purpose workflow using the `anthropics/claude-code-action@beta`
- **Triggers**: 
  - Issue comments with `@claude`
  - PR review comments with `@claude`
- **Behavior**: The beta action intelligently detects context and switches between:
  - PR review mode (provides feedback)
  - Issue implementation mode (attempts to implement, but results vary)
- **Status**: Works well for PR reviews, limited success for issue implementation

### 2. Claude Issue Implementation (`claude-issue-implementation.yml`)
- **Purpose**: Dedicated issue implementation using Claude Code CLI/SDK
- **Triggers**: Issue comments with `@claude` (ignores PR comments)
- **Behavior**: 
  - Installs Claude Code CLI
  - Runs `/close-issue` command using SDK with `-p` flag
  - Creates PR with implementation
- **Status**: New workflow designed for true OSE throughput

## Key Differences

| Feature | Claude Code Assistant | Claude Issue Implementation |
|---------|----------------------|---------------------------|
| Action Type | Uses beta action | Uses Claude Code CLI/SDK |
| Issue Implementation | Limited/unreliable | Full `/close-issue` command |
| PR Review | ✅ Excellent | ❌ Not supported |
| Knowledge Base | Built into action | Manually copied |
| OSE Alignment | Partial | Full |

## OSE (Outside and Slightly Elevated) Alignment

The Claude Issue Implementation workflow achieves true OSE:
- **Zero manual intervention**: Comment → Implementation → PR
- **Agent orchestration**: Dispatch work and walk away
- **Maximum throughput**: No babysitting required

## Usage

### For PR Reviews
Comment on any PR with:
```
@claude please review this PR
```

### For Issue Implementation
Comment on any issue with:
```
@claude please implement this
```

## Technical Details

### SDK Usage
The issue implementation workflow uses Claude Code SDK with the `-p` flag:
```bash
claude -p "/close-issue <number>" \
  --allowedTools 'Bash(git log:*),mcp__git__*,mcp__github-write__*' \
  --output-format json
```

This provides:
- Programmatic access suitable for CI
- Non-interactive execution
- JSON output for parsing
- Controlled tool permissions

### Authentication
Both workflows require:
- `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY`
- `GITHUB_TOKEN` (provided automatically)

## Future Improvements
- Docker image with pre-configured environment
- Better error handling and retry logic
- Parallel issue implementation
- Custom prompts for different issue types