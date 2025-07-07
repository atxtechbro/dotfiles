Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

## Core Principles
{{ INJECT:principles/tracer-bullets.md }}

### Test-Driven Development Principles
{{ INJECT:principles/verifiable-intent.md }}
{{ INJECT:principles/incremental-certainty.md }}
{{ INJECT:principles/failure-first-learning.md }}
{{ INJECT:principles/isolated-iteration.md }}
{{ INJECT:principles/progressive-refinement.md }}

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
Apply the principles to guide your implementation:
- **Verifiable Intent**: Define clear success criteria for the issue resolution
- **Failure-First Learning**: Understand how to detect when the issue is truly fixed
- **Incremental Certainty**: Build solution through verified steps, committing stable states
- **Isolated Iteration**: Keep testing criteria stable while evolving implementation
- **Progressive Refinement**: Start simple, add complexity as needed

Natural behaviors that should emerge:
- Create appropriate verification methods (tests, checks, validations)
- See verifications fail before implementing
- Use TodoWrite to track verified progress
- Commit only working code that advances toward the goal
- Follow existing patterns while innovating where beneficial

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
- **Bug report with clear reproduction** → Implementation path
- **Feature request approved by maintainer** → Implementation path  
- **Question already answered** → Quick close with link
- **Duplicate issue** → Quick close referencing original
- **Invalid/out of scope** → Quick close with explanation
- **Implemented in recent PR** → Quick close with PR reference

Remember: Act agentically. Make the decision and execute.
