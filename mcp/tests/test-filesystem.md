# Filesystem MCP Server Test

This document provides test prompts for verifying the Filesystem MCP server integration.

## Prerequisites

1. Complete the setup by running:
   ```bash
   cd ~/ppv/pillars/dotfiles/mcp
   ./setup-filesystem-mcp.sh
   ```

2. Restart your Amazon Q CLI or other MCP client.

## Test Prompts

### List Directory Contents

```
List the files in my home directory using the filesystem MCP server
```

### Read File Contents

```
Read the first 10 lines of ~/.bashrc using the filesystem MCP server
```

### Create a Test File

```
Create a file called test.txt in my home directory with the content "This is a test file created by the filesystem MCP server" using the filesystem MCP server
```

### Search for Files

```
Search for all markdown files in my home directory using the filesystem MCP server
```

## Expected Behavior

- The MCP client should invoke the Filesystem MCP server
- Operations should be performed on the local filesystem
- Results should match what you would see using standard command line tools
- No errors should be displayed in the client output
