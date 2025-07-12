Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

**Target-first approach**: Analyze issue → Triage path → Execute with feedback

## Step 1: Analyze & Triage
Use `mcp__github__get_issue` to read issue #{{ ISSUE_NUMBER }} and determine path:
- **Already resolved/implemented** → Quick close
- **Invalid/duplicate/out of scope** → Quick close with explanation  
- **Simple change** (docs, config, minor fix) → Lightweight workflow
- **Complex feature/refactor** → Full development workflow

## Path A: Quick Close
Add comment with `mcp__github__add_issue_comment`, close with `mcp__github__update_issue` (state: "closed"). Done.

## Path B: Lightweight Implementation
**For simple changes (docs, configs, minor fixes):**
1. **Orientation**: Check git status, current branch  
2. **Branch**: Create feature branch from main
3. **Target**: Define success criteria  
4. **Implement**: Make changes with TodoWrite tracking
5. **Verify**: Confirm target before committing
6. **PR**: Create with clear description

## Path C: Full Development  
**For complex features requiring isolation:**

1. **Worktree setup**: See `knowledge/procedures/worktree-workflow.md`
2. **Target definition**: Success criteria, failure detection, verification method  
3. **Tracer bullets**: Rapid iteration with ground truth feedback (see `knowledge/principles/tracer-bullets.md`)
4. **Git workflow**: Use `mcp__git__*` tools, conventional commits (see `knowledge/procedures/git-workflow.md`)
5. **PR + Retro**: Create PR, conduct mini-retro for systems learning (see `knowledge/procedures/post-pr-mini-retro.md`)

## Core Reminders
- **Subtraction**: Use minimal process for the complexity at hand
- **Selective optimization**: Match effort to impact  
- **Token economy**: Reference procedures vs injection
- **Versioning mindset**: Iterate existing solutions

Act agentically. Decide the path and execute.