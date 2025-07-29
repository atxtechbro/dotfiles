# Permissive Default, Surgical Removal

Start with maximum capability and transparency, then surgically remove only what violates security or the spilled coffee principle. This inverts traditional security thinking (restrictive by default) in favor of developer experience and visibility.

## Core Pattern
- **Server-level permissions**: `mcp__git` grants all tools from that server (wildcards not supported)
- **All access by default**: `additionalDirectories: ["//"]` for full filesystem access, `WebFetch(domain:*)`
- **Full visibility**: `verbose: true`, keep all output transparent
- **Surgical removal**: Remove only specific dangerous operations like `claude config set`

## Claude Code Directory Access Syntax
The `additionalDirectories` field extends Claude Code's built-in Edit/Write tools beyond the starting directory:

- **Full filesystem**: `["//"]` - Grants access to entire filesystem
- **Home directory**: `["~/"]` - All files under home
- **Parent directories**: `["../", "../../"]` - Navigate up from current location
- **Absolute paths**: `["//etc", "//usr/local"]` - Use `//` prefix for absolute paths
- **Home-relative**: `["~/ppv", "~/Documents"]` - Use `~/` prefix

**Note**: Without these entries, Claude's built-in Edit tool is restricted to the current working directory. The filesystem MCP server (`mcp__filesystem`) provides an alternative with unrestricted access.

## Why This Works
Traditional security says "deny all, allow specific" but in a trusted development environment:
- You need flexibility to explore and experiment
- Overly restrictive defaults create friction that leads to workarounds
- Better to see everything happening (verbose) than wonder what's hidden
- Surgical removal of specific risks is more maintainable than endless permission additions

## Examples from Practice
- Started with `Bash(claude config:*)` → removed only `set` operations
- Enabled full filesystem access with `additionalDirectories: ["//"]` rather than maintaining allowed lists
- Kept all MCP servers with server-level permissions rather than individual tool permissions
- Disabled telemetry/reporting at the source rather than filtering data
- Fixed "Path not found" error by using proper syntax (`//`) instead of glob patterns (`*`)

## Relationship to Other Principles
- **Developer Experience**: Maximum capability out of the box
- **Transparency in Agent Work**: Verbose by default makes actions visible
- **Subtraction Creates Value**: Remove dangerous operations, not add safe ones
- **Versioning Mindset**: Permissions can always be tightened later if needed

This principle acknowledges that in personal development environments, productivity and transparency trump restrictive security models.