# Brave Search MCP Server Test

This document provides test prompts for verifying the Brave Search MCP server integration.

## Prerequisites

1. Complete the setup by running:
   ```bash
   cd ~/ppv/pillars/dotfiles/mcp
   ./setup-brave-search-mcp.sh
   ```

2. Add your Brave Search API key to `~/.bash_secrets`:
   ```bash
   export BRAVE_SEARCH_API_KEY="your_api_key"
   ```

3. Restart your Amazon Q CLI or other MCP client.

## Test Prompts

### Basic Search

```
Search the web for "quantum computing basics" using Brave Search
```

### Search with Filters

```
Use Brave Search to find recent news about artificial intelligence
```

### Get Search Suggestions

```
What would Brave Search suggest for the query "climate change sol"
```

## Expected Behavior

- The MCP client should invoke the Brave Search MCP server
- Results should include relevant web search results
- No errors should be displayed in the client output
