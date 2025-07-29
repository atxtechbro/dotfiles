# tmux + git worktrees + Claude Code + Planning Mode

The quartet that delivers 100x productivity: tmux orchestrates, git worktrees isolate, Claude Code thinks, planning mode keeps you elevated. This is how you manage multiple AI agents in parallel without IDE context switching overhead.

## The Four Components

- **tmux**: Multi-session task orchestration with keyboard-driven pane management
- **git worktrees**: Complete repository isolation per issue (no cross-contamination)  
- **Claude Code CLI**: Context window management with resuming/branching capabilities
- **Planning Mode**: Default to thinking over doing - enforces [OSE principle](../principles/ose.md) mechanically

## Planning Mode: The Game Changer

**Enable by default** (recommended):
```bash
# In ~/.claude/settings.json
{
  "defaultMode": "plan"
}
```

**Or activate per-session**: Press `Shift+Tab` before running commands

**What changes:**
- Claude presents a plan BEFORE acting
- You review and approve/refine at the planning level
- No more "driving" at the implementation level
- Enforces OSE principle - you manage plans, not code

**The shift:**
- **Old way**: Watch Claude code, interrupt to course-correct
- **New way**: Review Claude's plan, approve with confidence

## Core Workflow

**New task received:**
`tmux pane + /close-issue <number> → Claude presents plan → You approve → automated workflow to PR`

**Parallel isolation:**
Automatic worktree creation per agent prevents interference between simultaneous tasks.

**Context management strategy:**
- Resume/branch existing conversations for related context
- Fresh 200k token windows for clean starts with embedded GitHub issue intelligence
- Favor fresh initialization over ephemeral long-running sessions

**Strategic context window usage:**
- 200k tokens = precious resource
- 25k (Anthropic) + 5k (knowledge/) = 30k baseline
- Git worktrees enable strategic fresh starts without losing isolation

**Broken window detection:**
Immediate issue creation/resolution cycle maintains snowball method momentum rather than cognitive debt accumulation.

## Key Benefits

- **True parallelism**: Multiple agents work simultaneously without interference
- **Strategic context**: Fresh 200k windows with knowledge/ directory state
- **Empowering workflow**: Fix broken windows immediately instead of noting them
- **Automation**: Slash commands handle worktree creation and management
- **Joy**: Git-like conversation branching and tmux orchestration feel delightful
- **Quality through planning**: Better plans mean smaller, focused PRs with less rework
- **Cognitive load reduction**: Review plans in batches instead of driving implementations serially
- **OSE enforcement**: Tool keeps you elevated - no more hands-on-keyboard heroics

## Related Procedures

- [Worktree Workflow](worktree-workflow.md) - technical isolation details
- [Slash Command Generation](slash-command-generation.md) - automation mechanics
- [Post-PR Mini Retro](post-pr-mini-retro.md) - continuous improvement

This workflow transforms development from sequential file-editing to parallel task orchestration - the foundation of the 100x productivity multiplier.