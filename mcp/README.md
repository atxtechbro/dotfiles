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

This script:
- Tests multiple GitHub MCP tools (search_repositories, list_issues, get_issue, etc.)
- Runs with the `--trust-all-tools` flag to bypass approval prompts
- Consolidates all logs to `~/ppv/pillars/dotfiles/logs/mcp-tests/`
- Creates timestamped log files for each test run

### Test Results

Our comprehensive testing shows:
- MCP servers initialize successfully (github and test)
- All tools are recognized and invoked with the correct parameters
- All tools fail with the same error pattern:
  - Tool execution begins but fails after ~0.15-0.53s
  - Error message: "[tool_name] invocation failed to produce a result"
- No debug output from our added logging is visible in the logs
- Consistent failure pattern across all GitHub MCP tools suggests a fundamental connection issue

### Log Analysis

All test logs are stored in a central location for easy comparison:

```
~/ppv/pillars/dotfiles/logs/mcp-tests/
├── mcp_test_20250508_123456_master.log       # Master log with all test results
├── mcp_test_20250508_123456_search_repositories.log  # Individual test log
└── mcp_test_20250508_123456_list_issues.log  # Individual test log
```

### Development Approach

We're following a tracer bullet development approach:

1. Add extensive logging at key points in the code
2. Build from source to incorporate logging changes
3. Run tests to gather diagnostic information
4. Fix one issue at a time, committing early and often
5. Repeat until the basic functionality works

### Next Steps

1. Fix remaining build errors in search.go implementation
2. Verify the GitHub token has appropriate permissions
3. Add more logging to the server initialization process
4. Check if the GitHub API is being rate limited
5. Investigate if there's a network connectivity issue
6. Check if there's a mismatch between the MCP server version and the client version
