# AI Provider Agnosticism

**Crisis-Proven**: Interchangeable AI providers for service outage resilience.

## Core Concept

AI services experience outages and rate limits. Provider agnosticism enables seamless switching between Claude Code and OpenAI Codex without workflow disruption. This was proven during Claude 500 errors requiring immediate fallback. Two providers are optimal - triple redundancy added complexity without improving throughput.

## Architecture Pattern

**Symmetric Capabilities**: Both providers access identical MCP servers and knowledge directory:

```bash
# Claude Code: Direct file reference via CLI flags
alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'

# OpenAI Codex: TOML configuration with mcp_servers sections
# Config file: .codex/config.toml with [mcp_servers.name] format
alias codex='codex --config "$DOT_DEN/.codex/config.toml" --add-dir "$DOT_DEN/knowledge"'
```

**Amazon Q Removed**: Through tracer bullet iteration, we discovered it hijacked shell sessions with qterm, breaking tmux. Removing it achieved better throughput - proving two providers are optimal.

## Implementation

- **Configuration Scripts**: `utils/configure-*.sh`
- **Knowledge Integration (symmetric)**:
  - Both providers read the same knowledge directory (`knowledge/`) and MCP config
  - Procedures are the single source of truth; providers are interchangeable at runtime

### Provider-Agnostic Invocation (Slash-Free)

We removed provider-specific slash commands in favor of natural-language, slug-based invocation that works identically in both Claude Code and OpenAI Codex.

- Convention: a sluggified prefix of a procedure filename in `knowledge/procedures` triggers that procedure
- Format: `"<slug-or-prefix> <args> [optional context]"`
- Examples:
  - `close-issue 123`
  - `use the close-issue procedure to close GitHub issue 123`
  - `extract-best-frame "/videos/clip.mp4"`

This eliminates dependence on provider-specific features (e.g., slash commands) while keeping procedures as the single source of truth. See:
- `knowledge/procedures/README.md` (Natural Language Invocation)
- `docs/procedures/issue-to-pr-detailed-workflow.md` (invocation examples)

Historical note: `.claude/command-templates/` are intentionally retired; they remain only as historical reference and are not required for core workflows.

## Crisis Response Matrix

| Primary Provider | Fallback | Scenario |
|-----------------|----------|----------|
| Claude Code | OpenAI Codex | Anthropic outage |
| OpenAI Codex | Claude Code | OpenAI disruption |

**Note**: Two providers are sufficient. Tracer bullet approach revealed Amazon Q was degrading performance.

## Provider Capabilities

### Claude Code (Anthropic)
- Model: claude-opus-4-1-20250805
- Strengths: Excellent documentation, developer-friendly ergonomics, complex reasoning
- MCP: CLI flag support

### OpenAI Codex (OpenAI)
- Model: gpt-5-2025-08-07
- Strengths: Novel OpenAI models, cutting-edge capabilities, unique availability
- MCP: TOML config with mcp_servers sections

## Implementation Example: MLflow Tracking

MLflow session tracking (`tracking/parse_session.py`) demonstrates provider agnosticism by extracting actual commands rather than maintaining provider-specific patterns. Instead of N×M complexity (N providers × M patterns), it uses a single parser that looks for `git`, `gh`, and bash commands regardless of AI formatting. This avoids provider detection entirely - working automatically with Claude Code, OpenAI Codex, and future assistants.

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across providers
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual providers experience issues, supporting continuous development workflow with triple redundancy.
