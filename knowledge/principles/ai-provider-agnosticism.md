# AI Provider Agnosticism

**Crisis-Proven**: Interchangeable AI providers for service outage resilience.

## Core Concept

AI services experience outages and rate limits. Provider agnosticism enables seamless switching between Claude Code and Amazon Q without workflow disruption. This was proven during Claude 500 errors requiring immediate fallback.

## Architecture Pattern

**Symmetric Capabilities**: Both providers access identical MCP servers and knowledge directory, but through different integration methods:

```bash
# Claude Code: Direct file reference via CLI flags
alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'

# Amazon Q: MCP import during setup (no CLI flag support)
# Setup runs: q mcp import --file "$DOT_DEN/mcp/mcp.json" global --force
alias q='q'
```

## Implementation

- **Configuration**: `.bash_aliases.d/ai-providers.sh`
- **Setup**: `utils/setup-provider-agnostic-mcp.sh`

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across providers
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual providers experience issues, supporting continuous development workflow.