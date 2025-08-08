---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !`gh issue view $1`

## Workspace Setup

- Create worktree: !`git worktree add "worktrees/issue-$1" -b "issue-$1"`

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}