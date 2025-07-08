# Git Workflow Rules

## MCP Git Tools Usage
**[Principle: systems-stewardship]** - Standardized tools create consistent, maintainable workflows
**IMPORTANT**: Use `mcp__git__*` tools instead of bash commands.
- **Chain Commands**: Use `mcp__git__git_batch` to combine multiple git operations efficiently

## Commit Standards
**[Principle: tracer-bullets]** - Each commit is a tracer round showing trajectory toward the target
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., api, ui, auth, config, docs)
- Use `Principle: <slug>` trailer when work resonates with a specific principle (e.g., `Principle: subtraction-creates-value`, `Principle: versioning-mindset`, `Principle: systems-stewardship`)
- **[Principle: versioning-mindset]** - Commit early and often with meaningful changes (history enables iteration)

## Branch Management

**Core principle: Working on main creates future work**. Every commit on main that should be on a feature branch guarantees recovery work: cherry-picking, rebasing, or complex git surgery. This violates the subtraction principle - we're adding unnecessary future tasks.

**Go slow to go fast**: The recovery tax compounds invisibly. A stale starting point pollutes every subsequent action - your PR carries ghost commits, review gets clouded by unintended diffs, context windows fill with noise. The principle isn't about git mechanics but about preserving clarity of intent. When we rush past orientation, we mortgage our future attention.

### Quick orientation checks (prevent future cleanup)
**[Principle: go-slow-to-go-fast]** - The recovery tax compounds invisibly when we skip orientation
1. `mcp__git__git_status` - Where am I? What's already changed?
2. Check current branch - Am I on main? Do I have uncommitted work?
3. **Is main current?** - `git fetch && git status`
   **[Principle: subtraction-creates-value]** - Behind origin/main means your PR will include unwanted commits
4. If changes exist on main - commit them properly or stash before branching

Starting from a stale foundation guarantees the recovery tax - double work to achieve what orientation would have prevented.

### Standards (not methods)
**[Principle: systems-stewardship]** - Consistent naming makes intent visible across the team
- Branch naming: `type/description` (e.g., `feature/add-authentication`, `fix/login-bug`)
- Issue suffix: `type/description-123` (e.g., `feature/add-authentication-512`)
- Order: Check surroundings → create branch → switch → work → commit

These standards make intent visible and prevent the recovery tax.

## Common Errors to Avoid
- Don't thank self when closing your own PRs

## Directory to Symlink Conversions
**[Principle: go-slow-to-go-fast]** - Rushing this operation creates git tree corruption requiring complex recovery
When converting a directory to a symlink (or vice versa), it's safer to use different names or do it in separate commits to avoid git tree corruption.

**Why**: Git can create invalid tree objects when the same path transitions from directory to symlink within a single commit, causing push failures with "duplicateEntries" errors.

**Safe approaches**:
1. Use different names (e.g., rename directory first, then create symlink)
2. Split into separate commits (remove directory in one commit, add symlink in another)
3. Create fresh branch from clean state if corruption occurs
