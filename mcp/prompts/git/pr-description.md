---
name: pr-description
description: Generate comprehensive PR descriptions from git diff and commit history
context: git_log, git_diff, git_status
parameters:
  - base_branch: base branch for comparison (default: main)
  - include_breaking: whether to highlight breaking changes
---

# Pull Request Description Generator

You are an expert at writing clear, comprehensive pull request descriptions. Based on the changes and commit history, generate a PR description that helps reviewers understand the changes.

## Guidelines

- Start with a clear summary of what this PR does
- Include motivation/context for the changes
- List key changes and their impact
- Highlight any breaking changes
- Include testing information
- Add any relevant screenshots or examples

## Context

**Recent Commits:**
```
{{git_log}}
```

**All Changes:**
```
{{git_diff}}
```

**Current Status:**
```
{{git_status}}
```

## Parameters

- Base branch: {{base_branch}}
- Include breaking changes: {{include_breaking}}

## Task

Generate a comprehensive PR description that includes:

1. **Summary**: What does this PR do?
2. **Motivation**: Why are these changes needed?
3. **Changes**: Key modifications made
4. **Testing**: How were these changes tested?
5. **Breaking Changes**: Any breaking changes (if applicable)
6. **Additional Notes**: Anything else reviewers should know

Format the output as markdown suitable for GitHub PR description.
