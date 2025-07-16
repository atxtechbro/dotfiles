Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

## Core Principle: Target-First Development
{{ INJECT:principles/tracer-bullets.md }}

## Step 1: Analyze the Issue
Use `mcp__github__get_issue` to read issue #{{ ISSUE_NUMBER }} and determine:
- Is this already resolved? → Quick close
- Does this need implementation? → Full workflow
- Is this invalid/duplicate? → Close with explanation
- **Is this a spike?** → Spike workflow (no PR)
- **Repository check**: If issue requires git operations in a different repo, STOP and ask human to restart session there. Claude Code cannot `cd` outside initial directory tree, breaking git workflows.
- Check recent merged PRs for similar patterns → `mcp__github__list_pull_requests` (state: "closed")
- Get issue comments with `mcp__github__get_issue_comments` to enrich understanding

**Clarity opportunity**: If the issue contains vague language ("doesn't work", "should handle", "it depends"), consider exploring with EARS patterns to surface hidden assumptions and edge cases. This often reveals interesting test scenarios and sparks productive conversations about the real requirements. See [EARS Requirements](knowledge/procedures/ears-requirements.md) for conversation-driven discovery techniques.

## Quick Close Path
If the issue is already resolved, invalid, or duplicate:
1. Add explanatory comment with `mcp__github__add_issue_comment`
2. Close with `mcp__github__update_issue` (state: "closed")
3. Done!

## Spike Workflow Path
If the issue is a spike:
1. Research. Prototype. Document findings.
2. Comment findings with `mcp__github__add_issue_comment`
3. Discuss with human
4. Close issue when done
5. **NO PR** - spikes deliver knowledge, not code

## Full Implementation Path
If the issue needs implementation:

### 1. Set Up Development
{{ INJECT:procedures/worktree-workflow.md }}

Apply to issue #{{ ISSUE_NUMBER }}:
- Replace <NUMBER> with {{ ISSUE_NUMBER }}
- Replace <description> with issue title slug

### 2. Implement Solution
Apply tracer bullets methodology:

**First, establish your target:**
- Define clear success criteria for the issue resolution
- Understand what failure looks like (how to detect when it's NOT fixed)
- Create verification methods (tests, checks, validations) that can detect hits/misses

**Then iterate with tracer rounds:**
- Fire and miss: See verifications fail (confirms target detection works)
- Adjust aim: Modify implementation while keeping target stable
- Fire again: Run verifications to check progress
- Use TodoWrite to track verified hits on target
- Each commit is a confirmed hit - only commit code that moves toward the target

**Natural behaviors that emerge:**
- Test-first development (you need a target before you can aim)
- Incremental progress through verified steps
- Progressive refinement from rough to precise shots
- Clear trajectory visible through commit history

{{ INJECT:procedures/git-workflow.md }}

### 3. Create Pull Request
- Push the feature branch to remote
- Create PR with `mcp__github__create_pull_request` following the PR template at `.github/PULL_REQUEST_TEMPLATE.md`
- Reference "Closes #{{ ISSUE_NUMBER }}" in PR body
- Add "Conduct post-PR mini retro" to your todo list

### 4. Iterate Based on Feedback
Keep worktree active for PR adjustments based on the tracer bullets principle. Only cleanup after PR is merged.

## REQUIRED: Post-PR Mini Retro (if PR was created)
**TRIGGER**: If you created a pull request, you MUST complete this step before finishing.

{{ INJECT:procedures/post-pr-mini-retro.md }}

## Decision Matrix
- **Spike label** → Spike workflow (research only)
- **Bug report with clear reproduction** → Implementation path
- **Feature request approved by maintainer** → Implementation path  
- **Question already answered** → Quick close with link
- **Duplicate issue** → Quick close referencing original
- **Invalid/out of scope** → Quick close with explanation
- **Implemented in recent PR** → Quick close with PR reference

Remember: Act agentically. Make the decision and execute.