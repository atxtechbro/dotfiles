# AI Provider Agnosticism

**Crisis-Proven**: Interchangeable AI providers for service outage resilience.

## Core Concept

AI services experience outages and rate limits. Provider agnosticism enables seamless switching between Claude Code and Amazon Q without workflow disruption. This was proven during Claude 500 errors requiring immediate fallback.

## Architecture Pattern

**Symmetric Configuration**: Both providers use identical MCP servers and knowledge directory patterns:

```bash
alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
alias q='q --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
```

## Implementation

- **Configuration**: `.bash_aliases.d/ai-providers.sh`
- **Setup**: `utils/setup-provider-agnostic-mcp.sh`

## Relationship to Other Principles

- **[Systems Stewardship](systems-stewardship.md)**: Consistent interfaces across providers
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Eliminates single points of failure
- **[OSE](ose.md)**: External perspective prevents vendor lock-in

This principle ensures AI assistant capabilities remain available even when individual providers experience issues, supporting continuous development workflow.