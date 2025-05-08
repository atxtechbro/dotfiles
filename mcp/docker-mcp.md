# Docker-based MCP Server Implementation

This document describes the Docker-based implementation of the GitHub MCP server for Amazon Q.

## Overview

Instead of building the GitHub MCP server from source using Go, this implementation uses the official Docker image provided by GitHub. This approach has several advantages:

1. **No Go dependency**: Users don't need to install Go or build the server from source
2. **Consistent environment**: The Docker container provides a consistent environment for the MCP server
3. **Automatic updates**: When the Docker image is updated, users get the latest version automatically
4. **Isolation**: The MCP server runs in an isolated container, reducing potential conflicts

## Requirements

- Docker installed on the system
- GitHub Personal Access Token (same as the Go-based implementation)

## Implementation Details

The setup script checks for Docker availability and creates a wrapper script that runs the GitHub MCP server using Docker. If Docker is not available but Go is, it falls back to building from source.

### Wrapper Script

The wrapper script (`github-mcp-wrapper`) handles:

1. Checking for the GitHub token in the environment or secrets file
2. Running the Docker container with the appropriate environment variables
3. Passing the stdio argument to the container

```bash
#!/bin/bash
# Wrapper script for GitHub MCP server using Docker

# Check if token is in environment
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  # Try to get from secrets file
  if [ -f "$HOME/.bash_secrets" ]; then
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets"; then
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" | cut -d '=' -f2)
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    echo "Warning: Using placeholder token for testing. GitHub API calls will fail." >&2
  fi
fi

# Run the GitHub MCP server using Docker
exec docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" \
  ghcr.io/github/github-mcp-server stdio
```

## Fallback Mechanism

If neither Docker nor Go is available, the setup script creates a placeholder wrapper that shows an error message when executed.

## Advantages Over Go-based Implementation

1. **Simpler setup**: No need to clone the repository or build from source
2. **Smaller footprint**: No need to store the source code or build artifacts
3. **Consistent behavior**: The Docker image is tested and maintained by GitHub
4. **Cross-platform**: Works on any system with Docker installed

## Limitations

1. **Docker dependency**: Requires Docker to be installed
2. **Container overhead**: Running in a container adds some overhead
3. **Network access**: The container needs network access to communicate with GitHub API

## Testing

To test the Docker-based implementation:

```bash
source mcp/setup.sh
source ~/.bash_secrets
Q_LOG_LEVEL=trace q chat --no-interactive --trust-all-tools "try to use the github___search_repositories tool to search for 'amazon-q', this is a test"
```

This should show the GitHub MCP server loading successfully and attempting to use the search_repositories tool.
