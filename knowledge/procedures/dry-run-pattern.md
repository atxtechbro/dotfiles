# Dry-Run Pattern for Slash Commands

Add `--dry-run` to commands that modify git state, process large files, or have long execution times (>30s).

**Add to:** extract-best-frame ✅, close-issue ✅
**Skip:** retro (conversational), create-issue (low risk)

**Implementation:** See extract-best-frame.md or close-issue.md for working examples.

**Pattern:**
1. Detect flags: `--dry-run`, `--json`
2. Show preview: config, planned steps, would-be commands
3. Exit before destructive operations

**Related:** config-in-environment.md, developer-experience principle
