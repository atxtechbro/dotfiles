# Issue-to-PR Workflow

The mechanical workflow that delivers value: from GitHub issue to merged pull request.

## The Complete Flow

```
GitHub Issue → Planning Mode → Implementation → Pull Request → Review → Merge
```

## Step-by-Step Mechanics

### 1. GitHub Issue Defines the Work

Every task starts as a GitHub issue:
- Clear problem statement
- Success criteria defined
- Labels indicate type (bug, feature, spike)

**Anti-pattern**: Starting work without an issue leads to scope creep and unclear PRs.

### 2. Planning Mode Review

Run `/close-issue <number>` with planning mode (default):
- Claude analyzes the issue
- Presents a plan for review
- You approve, refine, or reject

**Key insight**: This shifts you from "driving" to "managing" - you review plans, not implementation details.

### 3. Implementation in Isolation

Once plan is approved:
- Automatic worktree creation for complete isolation
- Claude implements in focused sessions
- Each commit represents verified progress

**Tools involved**:
- [Git worktrees](worktree-workflow.md) for isolation
- [Git workflow](git-workflow.md) for commits
- MCP tools for file operations

### 4. Pull Request Packages the Solution

Implementation complete:
- Push branch to remote
- Create PR referencing "Closes #<issue>"
- PR description explains the solution

**Quality gates**:
- Small, focused changes (planning mode enables this)
- Clear connection to original issue
- Tests pass, linting clean

### 5. Review Completes the Cycle

PR review happens at the right altitude:
- Review the solution, not individual lines
- Verify it solves the original issue
- Merge when approved

### 6. Optional: Post-PR Retro

For significant work:
- Run [post-PR mini retro](post-pr-mini-retro.md)
- Capture learnings
- Update procedures if needed

## Why This Works

1. **Clear boundaries**: Issues define WHAT, PRs deliver solutions
2. **Parallel execution**: Multiple issues → multiple agents → multiple PRs
3. **Quality through planning**: Better plans = better PRs
4. **Reduced cognitive load**: Review plans and PRs, not live coding

## Configuration

Enable planning mode by default:
```bash
# In ~/.claude/settings.json
{
  "defaultMode": "plan"
}
```

## Related

- [tmux + git worktrees + Claude Code + Planning Mode](tmux-git-worktrees-claude-code.md) - The complete productivity system
- [OSE Principle](../principles/ose.md) - Why this workflow embodies management over doing