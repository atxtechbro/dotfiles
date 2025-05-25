# MCP Setup Utilities

This directory contains utility scripts that provide shared functionality for MCP server setup scripts.

## Available Utilities

### mcp-setup-utils.sh

This script provides common functions used across multiple MCP setup scripts to reduce code duplication and ensure consistent behavior.

#### Functions

- `check_docker_installed()` - Check if Docker is installed
- `check_dotfiles_repo()` - Check if we're in the dotfiles repository
- `get_repo_root()` - Get the repository root directory
- `setup_mcp_servers_repo()` - Clone or update the MCP servers repository
- `build_mcp_docker_image()` - Build Docker image for a specific MCP server
- `update_secrets_template()` - Update .bash_secrets.example with API credentials template
- `print_setup_complete()` - Print setup completion message

#### Usage

To use these utilities in a setup script:

```bash
# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

# Use the functions
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)
setup_mcp_servers_repo
build_mcp_docker_image "your-server-name"
```

## Adding New Utilities

When adding new utility functions:

1. Consider whether the function is general enough to be useful across multiple setup scripts
2. Add clear documentation for the function's purpose and parameters
3. Include error handling for common failure cases
4. Test the function with different input scenarios
