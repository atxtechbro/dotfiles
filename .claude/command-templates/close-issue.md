---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !`gh issue view $1`

## Workspace Setup

- Create worktree: !`git worktree add "../issue-$1" -b "issue-$1" 2>&1 | grep -v "fatal" || echo "Using current directory"`

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}