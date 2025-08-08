---
description: Mine gleanings through eager evolution of living systems
---

## Current Context

- Branch: !`git branch --show-current`
- PR status: !`gh pr view --json number,title,state 2>/dev/null | jq -r '"PR #\(.number): \(.title) [\(.state)]"' || echo "Not in a PR branch"`
- Changed files: !`git status --short | head -5 || echo "Clean working directory"`

## Recent Work

- Recent commits: !`git log --oneline -10 --author="$(git config user.email)" 2>/dev/null || git log --oneline -10`

# Retro Command Template

{{ INJECT:procedures/retro-procedure.md }}
{{ INJECT:principles/eager-evolution.md }}