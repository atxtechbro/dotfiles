# Environment-Specific MCP Configuration

This document describes the environment-specific MCP server configuration system implemented in the dotfiles repository.

## Overview

The system allows you to automatically enable or disable certain MCP servers based on your environment (work, personal, development, production). This is particularly useful for:

- Preventing unnecessary connection attempts to work-specific servers on personal machines
- Reducing startup time by eliminating connection attempts to servers that will never succeed
- Maintaining a single source of truth for MCP configuration while adapting to different environments

## How It Works

1. Set the `WORK_MACHINE` environment variable in your `~/.bash_exports.local` file:
   ```bash
   # Set to "true" on work machines, "false" on personal machines
   export WORK_MACHINE="false"
   ```

2. The setup script will automatically filter MCP servers based on your environment:
   - On personal machines (`WORK_MACHINE="false"`), work-specific servers like Atlassian are removed
   - On work machines (`WORK_MACHINE="true"`), all servers are kept

3. You can customize which servers are disabled in each environment by editing the arrays in `utils/mcp-environment.sh`:
   ```bash
   PERSONAL_DISABLED_SERVERS=("atlassian" "jira" "confluence")
   DEVELOPMENT_DISABLED_SERVERS=()
   PRODUCTION_DISABLED_SERVERS=("experimental" "beta")
   ```

## Implementation Details

The implementation follows these principles:

1. **DRY (Don't Repeat Yourself)**: Common functionality is abstracted into reusable functions
2. **Single Source of Truth**: MCP configuration is maintained in one place
3. **Environment Detection**: Automatically determines the current environment
4. **Extensibility**: Easy to add new environments or servers
5. **Maintainability**: Clear separation of concerns and well-documented code

## Adding New Servers

To add a new server to the disabled list for a specific environment:

1. Edit `utils/mcp-environment.sh`
2. Add the server name to the appropriate array:
   ```bash
   PERSONAL_DISABLED_SERVERS=("atlassian" "jira" "confluence" "new-server")
   ```

## Adding New Environments

To add a new environment:

1. Edit `utils/mcp-environment.sh`
2. Add a new array for the environment:
   ```bash
   NEW_ENV_DISABLED_SERVERS=("server1" "server2")
   ```
3. Update the `detect_environment` and `filter_mcp_config` functions to handle the new environment

This approach follows the "Spilled Coffee Principle" by ensuring your MCP configuration is automatically tailored to each environment without manual intervention.
