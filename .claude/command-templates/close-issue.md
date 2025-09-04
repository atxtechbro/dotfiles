---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !gh issue view $1

## Workspace Setup

!SLUG=$(gh issue view $1 --json title -q .title | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//' | cut -c1-50)
!git worktree add "worktrees/$1-${SLUG}" -b "$1-${SLUG}"
!cd "worktrees/$1-${SLUG}"

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}