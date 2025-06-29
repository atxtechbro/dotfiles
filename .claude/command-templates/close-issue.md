Complete and implement GitHub issue #{{ ISSUE_NUMBER }} (not just close it!) - analyze whether it needs full implementation or quick closure.

**IMPORTANT**: The `/close-issue` command means "work on and complete the issue" which results in automatic closure when the PR merges. Only literally close the issue without implementation if it's already resolved, duplicate, or invalid.

## Core Principles
{{ INJECT:principles/tracer-bullets.md }}

## Step 1: Analyze the Issue
Use `mcp__github__get_issue` to read issue #{{ ISSUE_NUMBER }} and determine:
- Is this already resolved? → Quick close
- Does this need implementation? → Full workflow
- Is this invalid/duplicate? → Close with explanation
- Check recent merged PRs for similar patterns → `mcp__github__list_pull_requests` (state: "closed")
- Get issue comments with `mcp__github__get_issue_comments` to enrich understanding

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
- Create PR with `mcp__github__create_pull_request` following the PR template at `.github/PULL_REQUEST_TEMPLATE.md`
- Reference "Closes #{{ ISSUE_NUMBER }}" in PR body
- Add "Conduct post-PR mini retro" to your todo list

### 4. Cleanup
Remove worktree after PR is created.

## REQUIRED: Post-PR Mini Retro (if PR was created)
**TRIGGER**: If you created a pull request, you MUST complete this step before finishing.

{{ INJECT:procedures/post-pr-mini-retro.md }}

## Decision Matrix

**Default assumption: Issues need implementation unless proven otherwise.**

### → Full Implementation Path (create PR that closes issue):
- **Bug report with clear reproduction**
- **Feature request approved by maintainer**
- **Enhancement with clear value**
- **Documentation improvements**
- **Any valid issue that hasn't been addressed**

### → Quick Close Path (close without implementation):
- **Question already answered** → Close with link to answer
- **Duplicate issue** → Close referencing original issue
- **Invalid/out of scope** → Close with polite explanation
- **Already implemented in recent PR** → Close with PR reference
- **No longer relevant** → Close with explanation

Remember: When in doubt, lean toward implementation. The issue was created for a reason.