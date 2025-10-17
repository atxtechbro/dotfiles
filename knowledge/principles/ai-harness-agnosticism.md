# AI Harness Agnosticism

**Crisis-Proven**: Interchangeable AI harnesses for service outage resilience.

## Core Concept

AI development harnesses experience outages and rate limits. Harness agnosticism enables seamless switching between Claude Code, OpenAI Codex, Cursor, and GitHub Copilot without workflow disruption. This was proven during Claude 500 errors requiring immediate fallback. Two harnesses are optimal - triple redundancy added complexity without improving throughput.

The challenge isn't switching LLM models (trivial in most tools) - it's switching the **development harnesses** themselves: the interfaces, configurations, and integration approaches that differ significantly across tools.

## Architecture Pattern

**Symmetric Capabilities**: Both harnesses access identical MCP servers and knowledge directory:

```bash
# Claude Code: Direct file reference via CLI flags
alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'

# OpenAI Codex: TOML configuration with mcp_servers sections
# Config file: .codex/config.toml with [mcp_servers.name] format
alias codex='codex --config "$DOT_DEN/.codex/config.toml" --add-dir "$DOT_DEN/knowledge"'
```

**Amazon Q Removed**: Through tracer bullet iteration, we discovered it hijacked shell sessions with qterm, breaking tmux. Removing it achieved better throughput - proving two harnesses are optimal.

## Implementation

- **Configuration Scripts**: `utils/configure-*.sh`
- **Knowledge Integration (symmetric)**:
  - Both harnesses read the same knowledge directory (`knowledge/`) and MCP config
  - Procedures are the single source of truth; harnesses are interchangeable at runtime

### Harness-Agnostic Invocation (Slash-Free)

We removed harness-specific slash commands in favor of natural-language, slug-based invocation that works identically across Claude Code, OpenAI Codex, Cursor, and GitHub Copilot.

- Convention: a sluggified prefix of a procedure filename in `knowledge/procedures` triggers that procedure
- Format: `"<slug-or-prefix> <args> [optional context]"`
- Examples:
  - `close-issue 123`
  - `use the close-issue procedure to close GitHub issue 123`
  - `extract-best-frame "/videos/clip.mp4"`

This eliminates dependence on harness-specific features (e.g., slash commands) while keeping procedures as the single source of truth. See:
- `knowledge/procedures/README.md` (Natural Language Invocation)
- `docs/procedures/issue-to-pr-detailed-workflow.md` (invocation examples)

Historical note: `.claude/command-templates/` are intentionally retired; they remain only as historical reference and are not required for core workflows.

## Crisis Response Matrix

| Primary Harness | Fallback | Scenario |
|-----------------|----------|----------|
| Claude Code | OpenAI Codex | Anthropic outage |
| OpenAI Codex | Claude Code | OpenAI disruption |

**Note**: Two harnesses are sufficient. Tracer bullet approach revealed Amazon Q was degrading performance.

## Harness Capabilities

### Claude Code (Anthropic)
- Model: claude-sonnet-4-5-20250929
- Strengths: Excellent documentation, developer-friendly ergonomics, complex reasoning
- MCP: CLI flag support

### OpenAI Codex (OpenAI)
- Model: gpt-5-2025-08-07
- Strengths: Novel OpenAI models, cutting-edge capabilities, unique availability
- MCP: TOML config with mcp_servers sections

### Future Harnesses

This architecture extends to other AI development harnesses like Cursor and GitHub Copilot by:
- Mounting the same knowledge directory
- Providing symmetric MCP server access
- Supporting natural-language procedure invocation

## What Makes Harnesses Different?

Each development harness has unique:
- **Configuration formats**: CLI flags vs TOML vs JSON vs UI settings
- **MCP server integration**: Different mounting and connection strategies
- **Invocation patterns**: Slash commands vs natural language vs keyboard shortcuts
- **Ergonomics**: Different UIs, workflows, and developer experiences
- **Knowledge directory mounting**: Different strategies for context injection

This principle solves the hard problem: making these fundamentally different **tools** interchangeable, not just swapping underlying models.

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across harnesses
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual harnesses experience issues, supporting continuous development workflow with dual redundancy.
