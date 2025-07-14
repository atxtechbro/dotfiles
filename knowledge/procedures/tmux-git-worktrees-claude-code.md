# tmux + git worktrees + Claude Code

The triumvirate trinity that delivers 100x productivity: tmux orchestrates, git worktrees isolate, Claude Code executes. This is how you manage multiple AI agents in parallel without IDE context switching overhead.

## The Three Components

- **tmux**: Multi-session task orchestration with keyboard-driven pane management
- **git worktrees**: Complete repository isolation per issue (no cross-contamination)  
- **Claude Code CLI**: Context window management with resuming/branching capabilities

## Core Workflow

**New task received:**
`tmux pane + /close-issue <number> → automated workflow to PR`

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

## Related Procedures

- [Worktree Workflow](worktree-workflow.md) - technical isolation details
- [Slash Command Generation](slash-command-generation.md) - automation mechanics
- [Post-PR Mini Retro](post-pr-mini-retro.md) - continuous improvement

This workflow transforms development from sequential file-editing to parallel task orchestration - the foundation of the 100x productivity multiplier.