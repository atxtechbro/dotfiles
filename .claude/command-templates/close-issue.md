---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !gh issue view $1

## Workspace Setup

!TITLE=$(gh issue view $1 --json title -q .title)
!SLUG=$(python3 -c "import re, sys; s=re.sub(r'[^a-z0-9]+', '-', sys.argv[1].lower()).strip('-')[:50]; print(s)" "$TITLE")
!git worktree add "worktrees/$1-${SLUG}" -b "$1-${SLUG}"
!cd "worktrees/$1-${SLUG}"

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}