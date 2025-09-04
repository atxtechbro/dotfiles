# Command Lifecycle Management

This document describes the lifecycle of Claude slash commands in the dotfiles repository, from creation through maintenance to retirement.

## Principles

- **systems-stewardship**: Single source of truth for commands (templates)
- **subtraction-creates-value**: Remove orphaned commands to maintain clarity
- **defensive-programming**: Validate command synchronization at multiple stages

## Command Lifecycle Phases

### 1. Creation

New commands begin as templates in `.claude/command-templates/`:

```bash
# Create a new command template
vim .claude/command-templates/my-new-command.md

# Generate the command for all providers
utils/generate-commands.sh
```

Templates support:
- `{{ INJECT:path }}` - Include content from knowledge directory
- `{{ ISSUE_NUMBER }}` - Dynamic variable substitution
- Provider-specific customization in generate-commands.sh

### 2. Generation

The `generate-commands.sh` script:
1. **Cleans orphaned commands** via `sync-claude-commands.sh --clean`
2. Processes templates through `prompt_orchestrator.py`
3. Adds provider-specific logging and validation
4. Outputs to provider directories (`~/.claude/commands/`, etc.)

### 3. Synchronization

Command synchronization is validated at three levels:

#### Pre-commit Hook
Automatically checks synchronization when committing template changes:
```bash
# Enable the hook (done by setup.sh)
git config core.hooksPath .githooks
```

#### CI/CD Pipeline
GitHub Actions validate synchronization on every push:
- Runs `sync-claude-commands.sh --check`
- Fails build if commands are out of sync

#### Manual Verification
```bash
# Check current sync status
utils/sync-claude-commands.sh --check

# View detailed status with --verbose
utils/sync-claude-commands.sh --check --verbose
```

### 4. Maintenance

#### Renaming Commands
1. Rename the template file
2. Run `utils/generate-commands.sh` (auto-removes old command)
3. Commit both the renamed template

#### Updating Commands
1. Edit the template in `.claude/command-templates/`
2. Run `utils/generate-commands.sh`
3. Changes propagate to all providers

#### Handling Orphaned Commands
Orphaned commands occur when templates are deleted but generated commands remain:

```bash
# Detect orphaned commands
utils/sync-claude-commands.sh --check

# Remove orphaned commands
utils/sync-claude-commands.sh --clean
```

### 5. Retirement

To retire a command:
1. Delete the template from `.claude/command-templates/`
2. Run `utils/generate-commands.sh` (auto-cleanup removes generated files)
3. Commit the template deletion

## Prevention Strategy

### Centralize Management
- **Infrastructure commands**: Keep in global dotfiles
- **Project-specific**: Use local `.claude/command-templates/`

### Regular Maintenance
- Run sync check weekly: `utils/sync-claude-commands.sh --check`
- Before major refactoring, clean orphaned commands
- Use pre-commit hooks to catch issues early

### Clear Separation
Document which commands belong where:
- **Global**: System-wide utilities, issue management, retros
- **Project**: Domain-specific commands, project workflows

## Troubleshooting

### Commands Not Generating
```bash
# Check template directory
ls -la .claude/command-templates/

# Verify prompt orchestrator
python utils/prompt_orchestrator.py --help

# Run with verbose output
utils/sync-claude-commands.sh --check --verbose
```

### Orphaned Commands Persist
```bash
# Force clean all orphaned
utils/sync-claude-commands.sh --clean

# Verify clean succeeded
utils/sync-claude-commands.sh --check
```

### CI/CD Failures
If CI fails on command sync:
1. Pull latest changes
2. Run `utils/generate-commands.sh` locally
3. Commit any changes to generated commands
4. Push to resolve CI failure

## Architecture

```
.claude/command-templates/     # Source templates (version controlled)
    ├── close-issue.md
    ├── create-issue.md
    └── retro.md
           ↓
    generate-commands.sh       # Processes templates
    sync-claude-commands.sh    # Cleanup orphaned
           ↓
~/.claude/commands/            # Generated commands (not in repo)
    ├── close-issue.md
    ├── create-issue.md
    └── retro.md
```

## Related Documentation

- [Slash Commands Overview](../../README.md#slash-commands-vendor-agnostic)
- [systems-stewardship principle](../principles/systems-stewardship.md)
- [subtraction-creates-value principle](../principles/subtraction-creates-value.md)