# Close Issue Detailed Guide

Complete workflow for analyzing and implementing GitHub issues.

## Step 1: Analyze the Issue

Use `mcp__github__get_issue` to read the issue and determine:
- Is this already resolved? → Quick close
- Does this need implementation? → Full workflow
- Is this invalid/duplicate? → Close with explanation
- **Is this a spike?** → Spike workflow (no PR)
- **Repository check**: If issue requires git operations in a different repo, STOP and ask human to restart session there. Claude Code cannot `cd` outside initial directory tree, breaking git workflows.
- Check recent merged PRs for similar patterns → `mcp__github__list_pull_requests` (state: "closed")
- Get issue comments with `mcp__github__get_issue_comments` to enrich understanding

**Clarity opportunity**: If the issue contains vague language ("doesn't work", "should handle", "it depends"), consider exploring with EARS patterns to surface hidden assumptions and edge cases. This often reveals interesting test scenarios and sparks productive conversations about the real requirements. See [EARS Requirements](../../knowledge/procedures/ears-requirements.md) for conversation-driven discovery techniques.

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
Follow [Worktree Workflow](../../knowledge/procedures/worktree-workflow.md) to create isolated development environment.

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

Follow [Git Workflow](../../knowledge/procedures/git-workflow.md) for commit standards.

### 3. Create Pull Request
- Push the feature branch to remote
- Look for PR template:
  - First check local repo: `.github/PULL_REQUEST_TEMPLATE.md`
  - If not found, use dotfiles fallback: `~/ppv/pillars/dotfiles/.github/PULL_REQUEST_TEMPLATE.md`
  - Inform which template is being used for transparency
- The GitHub Action will automatically create a PR following the discovered template
- Add "Conduct post-PR mini retro" to your todo list

### 4. Iterate Based on Feedback
Keep worktree active for PR adjustments based on the tracer bullets principle. Only cleanup after PR is merged.

If MCP tools fail during implementation, follow [MCP Error Reporting](../../knowledge/procedures/mcp-error-reporting.md) to create self-healing feedback loop.

## Decision Matrix

- **Spike label** → Spike workflow (research only)
- **Bug report with clear reproduction** → Implementation path
- **Feature request approved by maintainer** → Implementation path  
- **Question already answered** → Quick close with link
- **Duplicate issue** → Quick close referencing original
- **Invalid/out of scope** → Quick close with explanation
- **Implemented in recent PR** → Quick close with PR reference

Remember: Act agentically. Make the decision and execute.

## See Also

- [Issue to PR Workflow](../../knowledge/procedures/issue-to-pr-workflow.md) - High-level workflow overview
- [Tracer Bullets](../../knowledge/principles/tracer-bullets.md) - Target-first development
- [Post-PR Mini Retro](../../knowledge/procedures/post-pr-mini-retro.md) - Learning from implementation