# Claude Desktop MCP Integration

This document explains how to use Claude Desktop as your primary MCP client with Clojure MCP server integration.

## Why Claude Desktop?

Claude Desktop offers several advantages as an MCP client:

1. **No Native Tool Conflicts**: Unlike Amazon Q CLI, Claude Desktop doesn't have built-in bash/filesystem tools that might conflict with our Clojure MCP implementation
2. **Clean Integration**: Provides a straightforward way to integrate with our Clojure MCP server
3. **Better UI Experience**: Offers a dedicated desktop application interface rather than a terminal-based experience
4. **Consistent Experience**: Works the same way across different operating systems

## Setup Instructions

### Automated Setup

The easiest way to set up Claude Desktop with Clojure MCP integration is through our automated setup script:

```bash
# Run the setup script
bash ~/ppv/pillars/dotfiles/mcp/setup-claude-desktop-mcp.sh
```

This script will:
1. Install required dependencies (nodejs, npm, icoutils)
2. Install Claude Desktop from our fork (https://github.com/aaddrick/claude-desktop-debian)
3. Configure Claude Desktop to use our Clojure MCP server
4. Create a launcher script that automatically starts the Clojure MCP server when needed
5. Create a desktop entry for easy access

### Manual Setup

If you prefer to set up manually or need to troubleshoot:

1. Install Claude Desktop:
   ```bash
   git clone https://github.com/aaddrick/claude-desktop-debian.git
   cd claude-desktop-debian
   ./build.sh
   sudo apt install ./claude-desktop_*_amd64.deb
   ```

2. Configure MCP integration:
   ```bash
   mkdir -p ~/.config/Claude
   cat > ~/.config/Claude/mcp.json << EOF
   {
     "servers": [
       {
         "name": "clojure-mcp",
         "url": "http://localhost:7777",
         "enabled": true
       }
     ]
   }
   EOF
   ```

3. Start the Clojure MCP server:
   ```bash
   ~/ppv/pillars/dotfiles/mcp/clojure-mcp-wrapper.sh start
   ```

4. Launch Claude Desktop:
   ```bash
   claude-desktop
   ```

## Usage

1. Launch "Claude Desktop (MCP)" from your application menu or run `claude-desktop-mcp`
2. Sign in with your Claude account
3. Start using Claude with Clojure MCP integration

## Troubleshooting

### MCP Server Not Connecting

If Claude Desktop doesn't connect to the Clojure MCP server:

1. Check if the server is running:
   ```bash
   ps aux | grep clojure-mcp
   ```

2. Manually start the server if needed:
   ```bash
   ~/ppv/pillars/dotfiles/mcp/clojure-mcp-wrapper.sh start
   ```

3. Verify the MCP configuration:
   ```bash
   cat ~/.config/Claude/mcp.json
   ```

### Claude Desktop Not Starting

If Claude Desktop fails to start:

1. Try running from terminal to see error messages:
   ```bash
   claude-desktop
   ```

2. Check if the package is properly installed:
   ```bash
   dpkg -l | grep claude-desktop
   ```

3. Reinstall if needed:
   ```bash
   sudo apt install --reinstall ~/ppv/pillars/dotfiles/mcp/claude-desktop-debian/claude-desktop_*_amd64.deb
   ```

## Known Limitations

1. Claude Desktop for Linux is unofficial (based on https://github.com/aaddrick/claude-desktop-debian)
2. The UI shows "Claude for Windows" even though you're on Linux
3. Some features may not work exactly as they do on officially supported platforms

## Advantages Over Amazon Q CLI

1. No need to build from source to disable native bash/filesystem features
2. Cleaner integration with Clojure MCP server
3. Dedicated desktop application with better UI
4. No conflicts between native tools and MCP tools