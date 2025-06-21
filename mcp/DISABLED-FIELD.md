# MCP Server `disabled` Field Support

This document provides an overview of the implementation of the `disabled` field support in Amazon Q MCP client.

## Overview

Amazon Q CLI now properly supports the `disabled=true` field in MCP server configurations, allowing servers to be configured but not loaded until explicitly enabled. This feature enables more sophisticated MCP server management that aligns with our goal of creating intelligent, context-aware development environments.

## Implementation Details

The following changes were made to implement the `disabled` field support:

1. **MCP Configuration**
   - Updated `mcp.json` to include examples of servers with the `disabled` field
   - Added documentation for the `disabled` field in the MCP README

2. **Environment Utilities**
   - Added `set_disabled_servers` function to set disabled=true for servers based on environment
   - Added `enable_mcp_servers` function to enable specific servers
   - Added `disable_mcp_servers` function to disable specific servers
   - Updated documentation to explain how to use the `disabled` field with environment-specific configurations

3. **Utility Scripts**
   - Created `mcp-enable` script to enable specific servers
   - Created `mcp-disable` script to disable specific servers
   - Added `--list` option to show server status

4. **Examples and Tests**
   - Created `project-specific-servers.sh` to demonstrate how to enable/disable servers based on project type
   - Created `test-disabled-field.sh` to verify that the `disabled` field is working correctly

## Use Cases

The `disabled` field support enables the following use cases:

### 1. Conditional Server Loading

Configure MCP servers but keep them disabled by default, then enable them based on:
- Project type detection
- Environment variables
- User preferences
- Performance considerations

### 2. Development vs Production Environments

- Configure debug/development servers as disabled by default
- Enable only when `$ENV=development`

### 3. Project-Specific Servers

- Pre-configure servers for different project types (Python, Node.js, etc.)
- Enable only the relevant ones based on detected project structure

### 4. Performance Optimization

- Configure resource-intensive servers as disabled
- Enable only when specifically needed

### 5. Experimental Servers

- Add new/experimental MCP servers as disabled
- Enable for testing without affecting main workflow

## Reference

This implementation is based on the changes in [PR #257](https://github.com/aws/amazon-q-developer-cli-autocomplete/pull/257) of the Amazon Q Developer CLI.

## Next Steps

1. Test disabled server behavior with our existing MCP servers
2. Implement smart server enabling/disabling logic based on project context
3. Create more sophisticated examples for different use cases
4. Consider adding automatic project type detection to shell initialization