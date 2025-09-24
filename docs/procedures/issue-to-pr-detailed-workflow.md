# Issue-to-PR Detailed Workflow

The complete mechanical workflow from GitHub issue to merged pull request.

## The Complete Flow

```
GitHub Issue → Planning Mode → Implementation → Pull Request → Review → Merge
```

## Step-by-Step Mechanics

### 1. GitHub Issue Defines the Work

Every task starts as a GitHub issue:
- Clear problem statement  
- Success criteria defined
- Labels automatically assigned by Claude Code GitHub Action based on principles

**Anti-pattern**: Starting work without an issue leads to scope creep and unclear PRs.

### 2. Planning Mode Review

Invoke the Close Issue workflow using natural language (provider‑agnostic). Examples:
- `close-issue <number>`
- "use the close-issue procedure to close GitHub issue <number>"

The agent analyzes the issue, presents a plan for review, and you approve, refine, or reject.

**Key insight**: This shifts you from "driving" to "managing" - you review plans, not implementation details.

### 3. Implementation in Isolation

Once plan is approved:
- Automatic worktree creation for complete isolation
- Claude implements in focused sessions
- Each commit represents verified progress

**Tools involved**:
- [Git worktrees](../../knowledge/procedures/worktree-workflow.md) for isolation
- [Git workflow](../../knowledge/procedures/git-workflow.md) for commits
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

### 6. Post-Merge Workflow

After merging via GitHub UI:
1. Exit Claude Code
2. `git checkout main`
3. `git pull origin main`
4. `source setup.sh`
5. Start new terminal session
6. Restart Claude Code:
   - Resume last chat for context continuity
   - Or start fresh for new work

**Note**: This manual process ensures clean environment and updated configurations.

### 7. Optional: Post-PR Retro

For significant work:
- Run [retro procedure](../../knowledge/procedures/retro-procedure.md)
- Capture learnings
- Update procedures if needed
- Document any ghost procedures discovered - see [Procedure Creation](../../knowledge/procedures/procedure-creation.md)

## Why This Works

1. **Clear boundaries**: Issues define WHAT, PRs deliver solutions
2. **Parallel execution**: Multiple issues → multiple agents → multiple PRs
3. **Quality through planning**: Better plans = better PRs
4. **Reduced cognitive load**: Review plans and PRs, not live coding

## Configuration

Planning mode should be enabled by default for all users:
```bash
# In ~/.claude/settings.json
{
  "defaultMode": "plan"
}
```

**Recommendation**: Add this to your `setup.sh` or dotfiles to ensure all team members start with planning mode enabled. This enforces OSE principles from day one.

## Related

- [tmux + git worktrees + Claude Code + Planning Mode](../../knowledge/procedures/tmux-git-worktrees-claude-code.md) - The complete productivity system
- [OSE Principle](../../knowledge/principles/ose.md) - Why this workflow embodies management over doing
