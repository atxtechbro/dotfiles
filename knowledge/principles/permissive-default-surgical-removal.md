# Permissive Default, Surgical Removal

Start with maximum capability and transparency, then surgically remove only what violates security or the spilled coffee principle. This inverts traditional security thinking (restrictive by default) in favor of developer experience and visibility.

## Core Pattern
- **Wildcards over enumeration**: `mcp__git*` not 27 individual entries
- **All access by default**: `additionalDirectories: ["*"]`, `WebFetch(domain:*)`
- **Full visibility**: `verbose: true`, keep all output transparent
- **Surgical removal**: Remove only specific dangerous operations like `claude config set`

## Why This Works
Traditional security says "deny all, allow specific" but in a trusted development environment:
- You need flexibility to explore and experiment
- Overly restrictive defaults create friction that leads to workarounds
- Better to see everything happening (verbose) than wonder what's hidden
- Surgical removal of specific risks is more maintainable than endless permission additions

## Examples from Practice
- Started with `Bash(claude config:*)` → removed only `set` operations
- Enabled all directories access rather than maintaining allowed lists
- Kept all MCP servers with wildcards rather than individual permissions
- Disabled telemetry/reporting at the source rather than filtering data

## Relationship to Other Principles
- **Developer Experience**: Maximum capability out of the box
- **Transparency in Agent Work**: Verbose by default makes actions visible
- **Subtraction Creates Value**: Remove dangerous operations, not add safe ones
- **Versioning Mindset**: Permissions can always be tightened later if needed

This principle acknowledges that in personal development environments, productivity and transparency trump restrictive security models.