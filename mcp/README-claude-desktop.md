# Claude Desktop MCP Integration

This document explains how to configure Claude Desktop to use the Clojure MCP server.

## Prerequisites

- Claude Desktop must be installed:
  - **Windows/macOS**: Download from [https://claude.ai/download](https://claude.ai/download)
  - **Linux**: Use our fork at [https://github.com/atxtechbro/claude-desktop-debian](https://github.com/atxtechbro/claude-desktop-debian)

## Configuration

Claude Desktop needs to be configured to use only the Clojure MCP server. The configuration file location depends on your operating system:

### Windows
```
%APPDATA%\Claude\mcp.json
```

### macOS
```
~/Library/Application Support/Claude/mcp.json
```

### Linux
```
~/.config/Claude/mcp.json
```

The configuration file should contain:
```json
{
  "servers": [
    {
      "name": "clojure-mcp",
      "url": "http://localhost:7777",
      "enabled": true
    }
  ]
}
```

## Setup Script

For convenience, you can use the `configure-claude-desktop-mcp.sh` script to automatically create the proper configuration file for your operating system:

```bash
# Run the configuration script
bash ~/ppv/pillars/dotfiles/mcp/configure-claude-desktop-mcp.sh
```

## Linux Installation (if needed)

If you're on Linux and don't have Claude Desktop installed, you can use our fork of the Claude Desktop Debian package:

```bash
# Clone the repository
git clone https://github.com/atxtechbro/claude-desktop-debian.git
cd claude-desktop-debian

# Build and install
./build.sh
sudo apt install ./claude-desktop_*_amd64.deb
```

## Usage

1. Start the Clojure MCP server:
   ```bash
   ~/ppv/pillars/dotfiles/mcp/clojure-mcp-wrapper.sh start
   ```

2. Launch Claude Desktop
   - The application will automatically connect to the Clojure MCP server
   - You can verify this by checking if Clojure functions are available

## Troubleshooting

If Claude Desktop doesn't connect to the Clojure MCP server:

1. Verify the MCP configuration file exists and has the correct content
2. Ensure the Clojure MCP server is running
3. Restart Claude Desktop after making any configuration changes