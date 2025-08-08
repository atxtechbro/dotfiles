# AI Provider Agnosticism

**Crisis-Proven**: Interchangeable AI providers for service outage resilience.

## Core Concept

AI services experience outages and rate limits. Provider agnosticism enables seamless switching between Claude Code, Amazon Q, and OpenAI Codex without workflow disruption. This was proven during Claude 500 errors requiring immediate fallback, and now provides triple redundancy.

## Architecture Pattern

**Symmetric Capabilities**: All three providers access identical MCP servers and knowledge directory, but through different integration methods:

```bash
# Claude Code: Direct file reference via CLI flags
alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'

# Amazon Q: MCP import during setup (no CLI flag support)
# Setup runs: q mcp import --file "$DOT_DEN/mcp/mcp.json" global --force

# OpenAI Codex: TOML configuration with mcp_servers sections
# Config file: .codex/config.toml with [mcp_servers.name] format
alias codex='codex --config "$DOT_DEN/.codex/config.toml" --add-dir "$DOT_DEN/knowledge"'
```

## Implementation

- **Configuration Scripts**: `utils/configure-*.sh` 
- **Complex Installation**: `utils/install-amazon-q.sh`
- **Knowledge Integration**: 
  - Claude: Slash commands + knowledge directory
  - Amazon Q: Knowledge import during setup
  - Codex: AGENTS.md hierarchical system

## Crisis Response Matrix

| Primary Provider | First Fallback | Second Fallback | Scenario |
|-----------------|----------------|-----------------|----------|
| Claude Code | OpenAI Codex | Amazon Q | Anthropic outage |
| OpenAI Codex | Claude Code | Amazon Q | OpenAI disruption |
| Amazon Q | Claude Code | OpenAI Codex | AWS issues |

## Provider Capabilities

### Claude Code (Anthropic)
- Model: claude-opus-4-1-20250805
- Strengths: Excellent documentation, developer-friendly ergonomics, complex reasoning
- MCP: CLI flag support

### Amazon Q (AWS)
- Model: Amazon's proprietary
- Strengths: Rust-based, open source, cost-effective, AWS integration
- MCP: Import mechanism

### OpenAI Codex (OpenAI)
- Model: gpt-5-2025-08-07
- Strengths: Novel OpenAI models, cutting-edge capabilities, unique availability
- MCP: TOML config with mcp_servers sections

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across providers
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual providers experience issues, supporting continuous development workflow with triple redundancy.