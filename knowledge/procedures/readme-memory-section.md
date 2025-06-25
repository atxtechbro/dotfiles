# README Memory Section

Auto-updating README section that analyzes recent git commits to maintain context across Claude CLI sessions.

## Purpose

Addresses the "50 First Dates" problem where AI agents lose context between sessions. By embedding recent activity patterns directly in the README, every new session starts with awareness of:
- What files have been actively worked on
- What types of work have been done (feat, fix, docs)
- Which principles were applied
- Current focus areas

## How It Works

1. **Script**: `utils/update-readme-memory.py` analyzes git log
2. **GitHub Action**: Runs daily at 3 AM UTC or on push to main
3. **Updates**: Automatically commits changes to README.md

## Manual Update

```bash
# Update with default 7 days
python3 utils/update-readme-memory.py

# Update with custom timeframe
python3 utils/update-readme-memory.py 14  # Last 14 days
```

## What It Tracks

- **Activity Summary**: Total commits and files modified
- **Most Active Files**: Top 10 files by change frequency
- **Work Types**: Distribution of feat/fix/docs/etc commits
- **Active Components**: Which scopes see most activity
- **Applied Principles**: Which principles guide recent work
- **Recent Features**: Last 5 feature commits
- **Focus Areas**: High-level categorization of changes

## Benefits

- Every AI session starts with context
- Patterns emerge from actual work (not assumptions)
- Reinforces principles through visibility
- Creates feedback loop for improvement

Principle: systems-stewardship