# MCP Server Development

This directory contains documentation and tools for working with Model Context Protocol (MCP) servers.

## GitHub MCP Server

The GitHub MCP server provides tools for interacting with GitHub repositories, issues, pull requests, and more.

### Current Status

We're actively working on fixing issues with the GitHub MCP server. The main challenges are:

1. Connection issues between Amazon Q CLI and the GitHub MCP server
2. Logging and debugging the communication between components
3. Understanding the expected interfaces and data structures

### Testing

Use the test script to verify connectivity:

```bash
~/ppv/pillars/dotfiles/bin/test-github-mcp
```

This script runs tests with and without the `--trust-all-tools` flag to help diagnose issues.

### Development Approach

We're following a tracer bullet development approach:

1. Add extensive logging at key points in the code
2. Build from source to incorporate logging changes
3. Run tests to gather diagnostic information
4. Fix one issue at a time, committing early and often
5. Repeat until the basic functionality works

### Next Steps

1. Fix build errors in the search.go implementation
2. Ensure the search_repositories tool matches the expected interfaces
3. Test with the simplest possible query
4. Gradually expand functionality once the basic connection works
