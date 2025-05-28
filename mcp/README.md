# MCP Shell Server

This directory contains the configuration and setup scripts for the [sonirico/mcp-shell](https://github.com/sonirico/mcp-shell) MCP server, which provides fine-grained security controls for shell commands executed through Amazon Q CLI.

## Features

- **Command Whitelisting/Blacklisting**: Control which commands can be executed
- **Pattern Blocking**: Block dangerous command patterns (like `rm -rf /`)
- **Execution Limits**: Set timeouts and output size limits
- **Directory Restrictions**: Limit which directories commands can be executed in
- **Audit Logging**: Keep track of all executed commands

## Installation

To install the MCP shell server:

```bash
# Install the MCP shell server
./utils/install-mcp-shell.sh

# Register it with Amazon Q CLI
./mcp/setup-mcp-shell.sh
```

## Security Configuration

The security configuration is stored in `mcp/config/mcp-shell.yaml`. This configuration provides a balanced approach to security while allowing power users to perform common operations safely.

### Default Security Settings

- **Allowed Commands**: A comprehensive list of common utilities and development tools
- **Blocked Commands**: Dangerous operations like `rm -rf /` and fork bombs
- **Blocked Patterns**: Regex patterns to catch variations of dangerous commands
- **Execution Limits**: 60-second timeout and 5MB output limit
- **Directory Restrictions**: Limited to user directories like `/home`, `/tmp`, etc.
- **Audit Logging**: Enabled by default, logs stored in `~/.mcp-shell-audit.log`

### Customizing Security Settings

You can customize the security settings by editing the `mcp/config/mcp-shell.yaml` file. The configuration follows this structure:

```yaml
security:
  enabled: true
  allowed_commands:
    - command1
    - command2
  blocked_commands:
    - dangerous_command1
    - dangerous_command2
  blocked_patterns:
    - 'regex_pattern1'
    - 'regex_pattern2'
  max_execution_time: 60s
  max_output_size: 5242880
  allowed_working_directories:
    - /path1
    - /path2
  audit_log: true
  audit_log_path: ~/.mcp-shell-audit.log
```

## Usage with Amazon Q CLI

Once installed and registered, you can use the MCP shell server with Amazon Q CLI:

```bash
q chat
```

Then, you can ask Amazon Q to execute shell commands, which will be filtered through the security configuration.

Example prompts:
- "List all files in the current directory"
- "Show me the disk usage of this system"
- "Find all Python files in this project"

## Benefits

- **Enhanced Security**: Protection against accidental or malicious destructive commands
- **Audit Trail**: Keep track of all commands executed through Amazon Q
- **Controlled Environment**: Limit what Amazon Q can do on your system
- **Peace of Mind**: Use Amazon Q's shell capabilities without worrying about security risks