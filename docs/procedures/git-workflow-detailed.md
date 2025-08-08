# Git Workflow Detailed Rules

## Branch Management

**Core principle: Working on main creates future work**. Every commit on main that should be on a feature branch guarantees recovery work: cherry-picking, rebasing, or complex git surgery. This violates the subtraction principle - we're adding unnecessary future tasks.

**Go slow to go fast**: The recovery tax compounds invisibly. A stale starting point pollutes every subsequent action - your PR carries ghost commits, review gets clouded by unintended diffs, context windows fill with noise. The principle isn't about git mechanics but about preserving clarity of intent. When we rush past orientation, we mortgage our future attention.

### Quick orientation checks (prevent future cleanup)
1. Check git status - Where am I? What's already changed?
   → [subtraction-creates-value](../../knowledge/principles/subtraction-creates-value.md) (avoid recovery tax)
2. Check current branch - Am I on main? Do I have uncommitted work?
3. **Is main current?** - `git fetch && git status` - Behind origin/main means your PR will include unwanted commits
   → [subtraction-creates-value](../../knowledge/principles/subtraction-creates-value.md)
4. If changes exist on main - commit them properly or stash before branching

Starting from a stale foundation guarantees the recovery tax - double work to achieve what orientation would have prevented.

### Standards (not methods)
- Branch naming: `type/description` (e.g., `feature/add-authentication`, `fix/login-bug`)
- Issue suffix: `type/description-123` (e.g., `feature/add-authentication-512`)
- Worktree naming: `NUMBER-issue` (e.g., `1251-issue`, `42-issue`)
  → Developer ergonomics: Tab completion with issue number first (`cd worktrees/1251<tab>`)
- Order: Check surroundings → create branch → switch → work → commit
  → [subtraction-creates-value](../../knowledge/principles/subtraction-creates-value.md) (prevent recovery work)

These standards make intent visible and prevent the recovery tax.

## Directory to Symlink Conversions
When converting a directory to a symlink (or vice versa), it's safer to use different names or do it in separate commits to avoid git tree corruption.

**Why**: Git can create invalid tree objects when the same path transitions from directory to symlink within a single commit, causing push failures with "duplicateEntries" errors.

**Safe approaches**:
1. Use different names (e.g., rename directory first, then create symlink)
2. Split into separate commits (remove directory in one commit, add symlink in another)
3. Create fresh branch from clean state if corruption occurs

## Think-Tank Content in Worktrees
**CRITICAL**: Never add think-tank notes or personal content to worktree locations. Worktrees are temporary directories that will be deleted when cleanup occurs. Always use the main repository at `/think-tank/` for any persistent personal content, notes, or documentation.