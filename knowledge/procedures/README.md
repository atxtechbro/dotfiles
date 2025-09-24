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
- `command-lexicon.md` - Provider-agnostic natural language command mapping
- `slash-command-generation.md` - Optional wrappers for commands like `/close-issue`

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

Procedures can be invoked via natural language in any AI provider that loads the knowledge base. For example:
- "close-issue 123" → maps via Command Lexicon to Close Issue Procedure
- "use the close-issue procedure to close GitHub issue 123" → same outcome

This removes dependency on provider-specific slash commands while keeping them available as optional wrappers.
