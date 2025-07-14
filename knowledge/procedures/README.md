# Procedures

Actionable processes and workflows that evolve with experience.

## Documentation Philosophy

**Cookie Crumbs Pattern**: Each procedure documents not just the "what" but the "why" - leaving decision breadcrumbs for future developers (including your future self). This prevents the need to reverse-engineer decisions from git history or tribal knowledge.

**Key principles:**
- Document the context that led to specific choices
- Explain why alternatives were rejected
- Reference the problem state that necessitated the solution
- Leave traces of the decision-making process, not just the final outcome

## Core Procedures

- `fs-write-full-paths.md` - Always use absolute paths in fs_write operations
- `git-workflow.md` - Git conventions and branch management (includes documentation-over-git-history guidance)
- `post-pr-mini-retro.md` - Systems improvement retro after feature PRs (includes cookie crumbs questions)
- `worktree-workflow.md` - Git worktree workflow (beta/imperfect system)

## Future Procedure Ideas
- **Self-organizing README**: Automate README.md reorganization based on git log activity patterns (daily GitHub Action analyzing last 1000 commits)
