# Dry-Run Pattern for Slash Commands

**Pattern for adding `--dry-run` preview capability to Claude Code slash commands.**

## Purpose

Enable users to preview command execution plans before performing destructive or resource-intensive operations. This creates psychological safety, enables faster iteration, and surfaces configuration issues early.

## When to Add --dry-run

### MUST Have Dry-Run (High Value)

Commands that perform **destructive or irreversible actions**:

✅ **extract-best-frame** - Resource intensive (video processing, frame extraction)
- Why: Minutes of processing, large file generation, config validation
- Preview: FPS calculations, frame counts, output paths, would-be ffmpeg commands

✅ **close-issue** - Destructive git operations (commits, branches, PRs, worktrees)
- Why: Creates git state, pushes to remote, opens PRs
- Preview: Worktree location, branch name, commit message, PR details

### SHOULD Have Dry-Run (Medium Value)

Commands with **external side effects**:

⚠️ **create-issue** - Creates GitHub issue (low risk, but preview helpful)
- Why: External API call with side effect (creates issue)
- Preview: Title, body, labels, repository before creation
- Decision: Deferred until user requests

### OPTIONAL Dry-Run (Low Value)

Commands that are **conversational or read-only**:

⏸️ **retro** - Interactive dialogue, no destructive actions
- Why: Conversational Q&A, no state changes
- Could show: Personality selected, questions to be asked
- Decision: Skip (retro is meant to be collaborative conversation)

## Decision Criteria

**Add --dry-run if command:**
1. ✅ Modifies git state (commits, branches, worktrees, PRs)
2. ✅ Processes large files (videos, images, datasets)
3. ✅ Makes external API calls with side effects (create, update, delete)
4. ✅ Has long execution time (>30 seconds)
5. ✅ Requires user config to work correctly (config preview valuable)

**Skip --dry-run if command:**
1. ❌ Purely conversational (interactive Q&A)
2. ❌ Read-only operations (fetching data, displaying info)
3. ❌ Fast execution (<5 seconds)
4. ❌ No destructive actions

## Implementation Pattern

### 1. Update Invocation Documentation

Add optional modifiers to command header:

```markdown
## Invocation
- Primary command: "command-name <args>"
- Optional modifiers:
  - `--dry-run`: Preview execution plan without running commands
  - `--json`: Output in machine-readable JSON format
- Parsing rules:
  - Detect flags anywhere in user input after command name
  - Natural language variants accepted: "dry run", "preview"

Examples:
- "command-name arg" → Normal execution
- "command-name arg --dry-run" → Preview without execution
- "command-name arg --dry-run --json" → Machine-readable preview
```

### 2. Add Step 0: Parse Execution Modifiers

Insert after knowledge base loading, before implementation:

```bash
## Step 0: Parse Execution Modifiers

!# Parse flags from the user's command invocation
!DRY_RUN=false
!JSON_OUTPUT=false
!USER_INPUT="${USER_INPUT:-$*}"
!
!# Check for dry-run flag variants
!if echo "$USER_INPUT" | grep -qiE '(--dry-run|dry.run|preview|show.me.what.would.happen)'; then
!  DRY_RUN=true
!fi
!
!# Check for JSON output flag
!if echo "$USER_INPUT" | grep -qiE '(--json)'; then
!  JSON_OUTPUT=true
!fi
!
!# Show banner if dry-run detected
!if [ "$DRY_RUN" = "true" ]; then
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    echo '{"dry_run": true, "mode": "json", "command": "<command-name>"}'
!  else
!    echo "🧠 Dry Run Mode: <Command Name>"
!    echo "──────────────────────────────────────"
!    echo "Preview mode - no <destructive actions> will be performed"
!    echo ""
!  fi
!fi
```

### 3. Add Dry-Run Preview Logic

After safe read-only operations, before destructive actions:

```bash
## Step N: Dry-Run Preview (If Enabled)

!if [ "$DRY_RUN" = "true" ]; then
!  # Calculate planned values
!  PLANNED_VALUE_1="..."
!  PLANNED_VALUE_2="..."
!
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    # JSON format
!    cat <<EOF
!{
!  "dry_run": true,
!  "command": "<command-name>",
!  "planned_actions": [
!    {"step": 1, "description": "..."},
!    {"step": 2, "description": "..."}
!  ],
!  "would_execute": [
!    "command 1",
!    "command 2"
!  ]
!}
!EOF
!  else
!    # Human-readable format
!    echo ""
!    echo "<Context Title>"
!    echo "──────────────────────────────────────"
!    echo "Planned Actions:"
!    echo "  1. <action description>"
!    echo "  2. <action description>"
!    echo ""
!    echo "Would Execute Commands:"
!    echo "  \$ <command 1>"
!    echo "  \$ <command 2>"
!    echo ""
!    echo "──────────────────────────────────────"
!    echo "(No actions executed - dry-run mode)"
!  fi
!  exit 0
!fi
```

### 4. Safe Read-Only Operations

Operations that **CAN** run in dry-run mode:
- ✅ `gh issue view` (fetch issue details)
- ✅ `ffprobe` (get video metadata)
- ✅ `git status` (check repository state)
- ✅ Config file reading (`.agent-config.yml`)
- ✅ File existence checks (`[ -f "$file" ]`)

Operations that **MUST NOT** run in dry-run mode:
- ❌ `git commit`, `git add`, `git push`
- ❌ `git worktree add`, `git worktree remove`
- ❌ `gh pr create`, `gh issue create`
- ❌ `ffmpeg` (file generation)
- ❌ `mkdir -p`, `cp`, `mv` (file modifications)

## Output Formats

### Human-Readable (Default)

```
🧠 Dry Run Mode: <Command Name>
──────────────────────────────────────
Preview mode - no <actions> will be performed

<Context>: <Details>
──────────────────────────────────────
<Key>: <Value>
<Key>: <Value>

Planned Actions:
  1. <Step description>
  2. <Step description>
  3. <Step description>

Would Execute Commands:
  $ <command 1>
  $ <command 2>
  $ <command 3>

──────────────────────────────────────
(No actions executed - dry-run mode)

To execute for real, run without --dry-run flag
```

### JSON (Machine-Readable)

```json
{
  "dry_run": true,
  "command": "<command-name>",
  "input": {
    "<key>": "<value>"
  },
  "planned_actions": [
    {"step": 1, "description": "..."},
    {"step": 2, "description": "..."}
  ],
  "would_execute": [
    "<command 1>",
    "<command 2>"
  ],
  "execution_status": "skipped (dry-run mode)"
}
```

## Examples

### extract-best-frame (Implemented)

See `commands/extract-best-frame.md` for full implementation.

**Dry-run shows:**
- Resolved config (optimize_for, target_person, output paths)
- Adaptive FPS calculations
- Frame extraction plan (Round 1 + Round 2)
- Would-be ffmpeg commands

### close-issue (Implemented)

See `commands/close-issue.md` for full implementation.

**Dry-run shows:**
- Issue details (title, number, repository)
- Worktree location and branch name
- Commit message preview
- PR creation plan
- All git commands that would execute

## Testing Checklist

When adding --dry-run to a command:

- [ ] Dry-run flag detected correctly
- [ ] Natural language variants work ("dry run", "preview")
- [ ] Banner shows appropriate message
- [ ] Read-only operations execute (metadata fetching)
- [ ] Destructive operations skipped
- [ ] Human-readable output is clear and complete
- [ ] JSON output is valid and parsable
- [ ] `exit 0` called after dry-run preview
- [ ] Normal execution works without --dry-run flag

## Principles

This pattern supports:
- **Developer Experience** - Psychological safety, faster iteration
- **Tracer Bullets** - Preview before committing to execution
- **Config in Environment** - Validate config loading works
- **Systems Stewardship** - Consistent UX across commands

## See Also

- [Developer Experience Principle](../principles/developer-experience.md)
- [Config in Environment Principle](../principles/config-in-environment.md)
- [Extract Best Frame Command](../../commands/extract-best-frame.md)
- [Close Issue Command](../../commands/close-issue.md)
