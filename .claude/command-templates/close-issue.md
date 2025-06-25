Close GitHub issue #{{ ISSUE_NUMBER }} - determine if it needs implementation or just closure.

## Core Principles
{{ INJECT:principles/tracer-bullets.md }}

## Step 1: Analyze the Issue
Use `mcp__github__get_issue` to read issue #{{ ISSUE_NUMBER }} and determine:
- Is this already resolved? → Quick close
- Does this need implementation? → Full workflow
- Is this invalid/duplicate? → Close with explanation

## Quick Close Path
If the issue is already resolved, invalid, or duplicate:
1. Add explanatory comment with `mcp__github__add_issue_comment`
2. Close with `mcp__github__update_issue` (state: "closed")
3. Done!

## Full Implementation Path
If the issue needs implementation:

### 1. Set Up Development
{{ INJECT:procedures/worktree-workflow.md }}

Apply to issue #{{ ISSUE_NUMBER }}:
- Replace <NUMBER> with {{ ISSUE_NUMBER }}
- Replace <description> with issue title slug

### 2. Implement Solution
- Use TodoWrite to track implementation tasks
- Follow existing patterns in codebase
- Test changes as you go
- Run lint/typecheck if available

{{ INJECT:procedures/git-workflow.md }}

### 3. Create Pull Request
- Push the feature branch to remote
- Create PR with `mcp__github__create_pull_request`
- Reference "Closes #{{ ISSUE_NUMBER }}" in PR body
- PR will auto-close issue when merged
- Add "Conduct post-PR mini retro" to your todo list

### 4. Cleanup
Remove worktree after PR is created.

## REQUIRED: Post-PR Mini Retro (if PR was created)
**TRIGGER**: If you created a pull request, you MUST complete this step before finishing.

{{ INJECT:procedures/post-pr-mini-retro.md }}

## Decision Matrix
- **Bug report with clear reproduction** → Implementation path
- **Feature request approved by maintainer** → Implementation path  
- **Question already answered** → Quick close with link
- **Duplicate issue** → Quick close referencing original
- **Invalid/out of scope** → Quick close with explanation
- **Implemented in recent PR** → Quick close with PR reference

Remember: Act agentically. Make the decision and execute.