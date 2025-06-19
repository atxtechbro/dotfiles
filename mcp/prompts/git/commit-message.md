---
name: commit-message
description: Generate conventional commit messages based on staged changes
context: git_status, git_diff_staged
parameters:
  - type: optional, description of change type override
  - scope: optional, scope of the change
---

# Commit Message Generator

You are an expert at writing clear, conventional commit messages. Based on the staged changes shown below, generate a commit message that follows conventional commit format.

## Guidelines

- Use conventional commit format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep description under 50 characters
- Use imperative mood ("add" not "added")
- Include body if changes are complex

## Context

**Git Status:**
```
{{git_status}}
```

**Staged Changes:**
```
{{git_diff_staged}}
```

## Parameters

- Type override: {{type}}
- Scope: {{scope}}

## Task

Generate a conventional commit message for these staged changes. If the changes are complex, include a body explaining the reasoning.
