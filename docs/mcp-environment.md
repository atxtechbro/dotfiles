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

## Using the `disabled` Field

With the new `disabled` field support in Amazon Q CLI, you have two options for managing environment-specific servers:

### Option 1: Remove Servers (Original Method)

This completely removes servers from the configuration:

```bash
# In utils/mcp-environment.sh
filter_mcp_config "$MCP_CONFIG_FILE" "personal"
```

**Pros:**
- Servers won't appear in listings
- No chance of accidental connection attempts
- Cleaner configuration file

**Cons:**
- Cannot be easily re-enabled without editing the configuration
- Requires knowledge of the server configuration to add it back

### Option 2: Disable Servers (New Method)

This keeps servers in the configuration but marks them as disabled:

```bash
# In utils/mcp-environment.sh
set_disabled_servers "$MCP_CONFIG_FILE" "personal"
```

**Pros:**
- Servers can be easily enabled when needed using `mcp-enable`
- Configuration remains intact for reference
- Better visibility of available servers

**Cons:**
- Slightly larger configuration file
- Servers still appear in listings (but marked as disabled)

### Choosing the Right Approach

- **Use removal** for servers that should never be used in a particular environment
- **Use disabling** for servers that are occasionally needed but not by default

### Dynamic Server Management

You can now dynamically enable or disable servers based on context:

```bash
# Enable project-specific servers when entering a project directory
cd_hook() {
  if [[ -f "package.json" ]]; then
    mcp-enable nodejs-server
  fi
  
  if [[ -f "requirements.txt" ]]; then
    mcp-enable python-server
  fi
}
```

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
