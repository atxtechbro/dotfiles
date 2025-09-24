# Procedures

Actionable processes and workflows that evolve with experience.

## 🎯 Core Workflow

**Start here**: Our work follows a mechanical flow from issue to value delivery.

### [Issue-to-PR Workflow](issue-to-pr-workflow.md)
The complete flow: `GitHub Issue → Planning Mode → Implementation → Pull Request → Review → Merge`

This is THE workflow. Everything else supports this core process.

## Supporting Workflows

### Active Development
- `tmux-git-worktrees-claude-code.md` - The 100x productivity system with planning mode
- `git-workflow.md` - Git conventions and branch management  
- `worktree-workflow.md` - Git worktree isolation for parallel development
- (Formerly) slash-command-generation.md - Historical reference for Claude slash wrappers (no longer used)

### Quality & Improvement
- `retro-procedure.md` - Systems improvement retro and learning extraction
- `five-focusing-steps.md` - Identify and optimize constraints

### Conventions & Standards
- `coding-conventions.md` - File paths, Python tools, and other learned patterns
- `configuration-as-code.md` - Prefer declarative JSON over imperative scripts

### Tool Integration
- `mcp-client-integration.md` - Adding new MCP clients to the ecosystem
- `mcp-tool-logging.md` - MCP server tool-level logging
- `mcp-protocol-smoke-test.md` - Testing MCP protocol directly
- `mcp-prompts.md` - Adding prompts to MCP servers

### Tips & Setup
- `claude-code-tips.md` - Tips and shortcuts for Claude Code

## Natural Language Invocation

Provider-agnostic convention: a sluggified, partial starting match of a procedure name in `knowledge/procedures` signals which procedure to run.

- Format: `<slug-or-prefix> <args> [optional context]`
- Slug rule: `close-issue-procedure.md` → `close-issue`; `extract-best-frame-procedure.md` → `extract-best-frame`
- Partial match: the leading portion of the slug is acceptable (e.g., `close-issue 123` or `close 123`)
- Optional context: any trailing text is treated as guidance (constraints, preferences) and incorporated with graceful flexibility

Examples:
- `close-issue 123`
- `use the close-issue procedure to handle 123`
- `extract-best-frame "/videos/clip.mp4"`

This removes dependency on provider‑specific slash commands while keeping procedures as the single source of truth.
