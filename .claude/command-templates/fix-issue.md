Fix GitHub issue #{{ ARGUMENTS }} using established workflows.

Repository: atxtechbro/dotfiles

## Core Principles to Follow
{{ INJECT:principles/do-dont-explain.md}}
{{ INJECT:principles/tracer-bullets.md}}
{{ INJECT:principles/versioning-mindset.md}}

## Step 1: Understand the Issue
- Use mcp__github__get_issue to read issue #{{ ARGUMENTS }}
- Use TodoWrite to create a task list from the issue requirements

## Step 2: Set Up Development Environment

### Worktree Workflow
{{ INJECT:procedures/worktree-workflow.md}}

Apply to issue #{{ ARGUMENTS }}:
- Replace <NUMBER> with {{ ARGUMENTS }}
- Replace <description> with a brief issue description

## Step 3: Implement Solution

### Git Workflow Rules
{{ INJECT:procedures/git-workflow.md}}

Additional implementation guidelines:
- Check existing code patterns before implementing
- Use existing libraries (check package.json, cargo.toml, etc.)
- Follow established conventions in neighboring files
- Test changes as you go
- Run lint/typecheck commands if available

## Step 4: Create Pull Request
- Push branch with: `git push -u origin fix/<description>-{{ ARGUMENTS }}`
- Use mcp__github__create_pull_request referencing issue #{{ ARGUMENTS }}
- Include clear description of changes and testing performed

## Step 5: Post-PR Retro
After submitting the PR, conduct a mini retro:

{{ INJECT:procedures/post-pr-mini-retro.md}}

## Step 6: Cleanup
Return to main directory and remove worktree as documented above.

Remember: Act like an agent. Execute tasks directly.