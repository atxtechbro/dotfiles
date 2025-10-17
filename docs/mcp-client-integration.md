# MCP Client Integration Guide

This guide documents how to integrate new MCP (Model Context Protocol) clients with the dotfiles repository infrastructure.

## Overview

The dotfiles repository provides an AI harness-agnostic system for managing MCP servers and global context. This allows multiple AI development harnesses (Amazon Q, Claude Code, Cursor, GitHub Copilot, etc.) to share the same configuration and knowledge base.

## Key Components

### 1. MCP Server Configuration
- **Source**: `mcp/mcp.template.json` - Single source of truth for MCP server definitions with work/personal machine conditionals
- **Format**: Standard MCP JSON format with `mcpServers` object
- **Wrappers**: Shell scripts in `mcp/servers/` directory for server initialization

### 2. Global Context System
- **Source**: `knowledge/` directory containing principles and procedures
- **Structure**:
  - `knowledge/principles/` - Foundational development principles
  - `knowledge/procedures/` - Actionable development procedures

### 3. AI Harness Context
- **Source**: `knowledge/` directory automatically configured for each harness
- **Amazon Q**: Uses symlinked rules directory (`~/.amazonq/rules/`)
- **Claude Code**: Uses generated `CLAUDE.local.md` files with embedded context

## Adding a New MCP Client

### Step 1: Create Installation Script

Create `utils/install-<client-name>.sh`:

```bash
#!/bin/bash
# <Client Name> installation and update script

setup_<client_name>() {
    echo "Checking <Client Name> status..."
    
    # Check prerequisites (Node.js, etc.)
    # Install/update the client
    # Configure MCP servers
    
    configure_<client_name>_mcp
}

configure_<client_name>_mcp() {
    echo "Configuring MCP servers for <Client Name>..."
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    # Run the MCP generator instead of copying from a static file
    if [[ -x "$DOT_DEN/mcp/generate-mcp-config.sh" ]]; then
        "$DOT_DEN/mcp/generate-mcp-config.sh"
    fi
    
    # Determine where the client expects MCP configuration
    # Copy/symlink the configuration
    # Apply environment filtering if needed
}
```

### Step 2: Update AI Harness Setup

Add a new class to `utils/setup-ai-provider-rules.py`:

```python
class <ClientName>Setup(AIProviderSetup):
    """<Client Name> specific setup"""

    def __init__(self):
        super().__init__("<Client Name>")
        # Define target paths for global context

    def _setup_provider_specific(self):
        """Harness-specific setup logic"""
        # Implement how this harness loads global context
        # Options: symlinks, generated files, config files

    def _validate_setup(self):
        """Harness-specific validation"""
        # Verify setup completed correctly
```

### Step 3: Integrate with setup.sh

Add to `setup.sh` after the Claude Code section:

```bash
# <Client Name> CLI setup and management
echo -e "${DIVIDER}"
echo "Setting up <Client Name> CLI..."

if [[ -f "$DOT_DEN/utils/install-<client-name>.sh" ]]; then
  source "$DOT_DEN/utils/install-<client-name>.sh"
  setup_<client_name> || {
    echo -e "${RED}Failed to setup <Client Name> CLI completely.${NC}"
    echo "Installation instructions: <URL>"
  }
fi
```

### Step 4: Document Client-Specific Details

Create `docs/<client-name>-setup.md` documenting:
- Where the client looks for MCP configuration
- How the client loads global context
- Any client-specific environment variables
- Known limitations or quirks

## Client Integration Patterns

### Pattern 1: Symlink-Based (Amazon Q)
- Client supports directory-based rule discovery
- Create symlink: `~/.clientname/rules` → `~/ppv/pillars/dotfiles/knowledge`
- Minimal duplication, single source of truth

### Pattern 2: Generated Files (Claude Code)
- Client expects specific file format
- Generate `CLIENTNAME.local.md` with embedded content
- Run generation on each setup

### Pattern 3: Configuration File
- Client uses JSON/YAML configuration
- Generate config from `mcp/mcp.template.json` using `generate-mcp-config.sh`
- Apply environment-specific filtering

## Environment Detection

The system supports environment-specific MCP server filtering:
- Personal machines: All servers enabled
- Work machines: Work-appropriate servers only
- Detection via `WORK_MACHINE` environment variable

## Testing Integration

1. Run `source setup.sh` - Should install/configure the client
2. Verify MCP servers are available in the client
3. Verify global context is loaded (check principles/procedures)
4. Test with a simple task using MCP tools

## Maintenance

- Keep `mcp/mcp.template.json` as the single source of truth
- Generated configs are created at runtime via `generate-mcp-config.sh`
- Update wrapper scripts in `mcp/servers/` as needed
- Maintain backward compatibility with existing clients
- Document any client-specific workarounds