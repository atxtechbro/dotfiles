Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

**Target-first approach**: Analyze → Decide path → Execute with feedback

## Decision Matrix (Triage First)
- **Already resolved/implemented** → Quick close with reference
- **Invalid/duplicate/out of scope** → Quick close with explanation  
- **Simple change (docs, config, minor fix)** → Lightweight path
- **Complex feature/refactor** → Full development path

## Path 1: Quick Close
Add comment with `mcp__github__add_issue_comment`, close with `mcp__github__update_issue` (state: "closed"). Done.

## Path 2: Lightweight Implementation
**For simple changes (docs, configs, minor fixes):**
1. **Orientation**: Check git status and branch position
2. **Branch**: Create feature branch from current main
3. **Target**: Define success criteria (what does "fixed" look like?)
4. **Implement**: Make changes with TodoWrite tracking
5. **Verify**: Confirm target hit before committing
6. **PR**: Create with clear description, link to issue

## Path 3: Full Development
**For complex features requiring isolation:**
1. **Worktree setup**: `mcp__git__git_worktree_add` in ~/ppv/pillars/dotfiles/worktrees/
2. **Target definition**: Success criteria, failure detection, verification method
3. **Tracer bullets**: Rapid iteration with ground truth feedback
4. **Git workflow**: Use `mcp__git__*` tools, conventional commits
5. **PR + Retro**: Create PR, conduct mini-retro for systems learning

## Core Reminders
- **Subtraction**: Use minimal viable process for the complexity at hand
- **Selective optimization**: Match effort to impact - trivial issues get trivial treatment  
- **Tracer bullets**: Define target → iterate → verify → commit confirmed hits
- **Token economy**: Reference procedures (`knowledge/procedures/`) vs. injection

Act agentically. Decide the path and execute.