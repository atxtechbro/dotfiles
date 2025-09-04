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
- **Knowledge Integration**: 
  - Claude: Slash commands + knowledge directory
  - Codex: AGENTS.md hierarchical system

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

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across providers
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual providers experience issues, supporting continuous development workflow with triple redundancy.