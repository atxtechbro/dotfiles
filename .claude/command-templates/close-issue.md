---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

# Close Issue Command

This command now uses the CLI tool at `bin/close-issue` for provider-agnostic issue closing.

## Using the CLI Tool

The issue will be processed using the new CLI tool which:
1. Sets up the git worktree automatically
2. Aggregates the knowledge base
3. Generates the appropriate prompt
4. Can work with multiple AI providers (currently Claude, more coming)

!# Execute the close-issue CLI tool
!# This provides the same functionality but can also be called from command line
!bin/close-issue $1

## Alternative: Direct CLI Usage

You can also use this tool directly from the command line outside of Claude Code:
```bash
bin/close-issue <issue-number> [provider]
```

Examples:
- `bin/close-issue 123` - Process issue #123 with Claude (default)
- `bin/close-issue 123 claude` - Explicitly use Claude
- `bin/close-issue 123 amazonq` - Use Amazon Q (coming soon)