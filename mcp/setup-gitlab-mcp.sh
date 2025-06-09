#!/bin/bash

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Source the GitLab CLI installation script
DOTFILES_ROOT="$(cd "$CURRENT_SCRIPT_DIRECTORY/.." && pwd)"
source "$DOTFILES_ROOT/utils/install-glab.sh"

# Ensure GitLab CLI is installed and up to date
if ! ensure_glab_installed; then
    echo "Error: GitLab CLI installation failed. Cannot continue with GitLab MCP server setup."
    exit 1
fi

echo "GitLab CLI installation verified. Proceeding with GitLab MCP server setup..."

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# Create the GitLab MCP wrapper script
cat > "$CURRENT_SCRIPT_DIRECTORY/gitlab-mcp-wrapper.sh" << 'EOF'
#!/bin/bash

# Get GitLab token from GitLab CLI
if command -v glab &> /dev/null; then
  # Check if user is authenticated
  if ! glab auth status &> /dev/null; then
    echo "Error: Not authenticated with GitLab. Please run 'glab auth login' first." >&2
    exit 1
  fi
  
  # Get the token
  TOKEN=$(glab auth status -t 2>/dev/null | grep -oP 'Token: \K.*')
  
  # Check if token was retrieved successfully
  if [ -z "$TOKEN" ]; then
    echo "Error: Failed to retrieve GitLab token." >&2
    exit 1
  fi
  
  # Export the token as an environment variable
  export GITLAB_PERSONAL_ACCESS_TOKEN="$TOKEN"
else
  # Fall back to .bash_secrets if glab CLI is not available
  if [ -f "$HOME/.bash_secrets" ]; then
    source "$HOME/.bash_secrets"
  fi
  
  # Check if token is available
  if [ -z "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "Error: GITLAB_PERSONAL_ACCESS_TOKEN not found. Please authenticate with 'glab auth login' or set the token in ~/.bash_secrets" >&2
    exit 1
  fi
fi

# Set GitLab API URL if not already set
if [ -z "$GITLAB_API_URL" ]; then
  export GITLAB_API_URL="https://gitlab.com/api/v4"
fi

# Run the GitLab MCP server
exec npx -y @modelcontextprotocol/server-gitlab
EOF

# Make the wrapper script executable
chmod +x "$CURRENT_SCRIPT_DIRECTORY/gitlab-mcp-wrapper.sh"

# Update mcp.json to use the wrapper script
if grep -q "\"gitlab\":" "$CURRENT_SCRIPT_DIRECTORY/mcp.json"; then
    # Use sed to update the existing GitLab configuration
    sed -i 's/"gitlab": {[^}]*"command": "[^"]*"/"gitlab": {\n      "command": "gitlab-mcp-wrapper.sh"/g' "$CURRENT_SCRIPT_DIRECTORY/mcp.json"
    sed -i 's/"args": \[[^]]*\]/"args": []/g' "$CURRENT_SCRIPT_DIRECTORY/mcp.json"
    sed -i 's/"env": {[^}]*}/"env": {\n        "FASTMCP_LOG_LEVEL": "ERROR"\n      }/g' "$CURRENT_SCRIPT_DIRECTORY/mcp.json"
else
    # GitLab configuration doesn't exist, add it
    echo "Error: GitLab configuration not found in mcp.json. Please add it manually."
    exit 1
fi

echo "GitLab MCP server setup complete!"
echo "The server will use your GitLab CLI authentication token."
echo ""
echo "To authenticate with GitLab:"
echo "1. Personal Access Token (recommended):"
echo "   - Visit: https://gitlab.com/-/profile/personal_access_tokens"
echo "   - Create token with 'api' scope"
echo "   - Add to ~/.bash_secrets: export GITLAB_PERSONAL_ACCESS_TOKEN=\"your_token\""
echo "   - Then run: glab auth login --hostname gitlab.com --token \$GITLAB_PERSONAL_ACCESS_TOKEN"
echo "2. Interactive login: glab auth login --hostname gitlab.com"
echo ""
echo "For custom GitLab instances, replace gitlab.com with your hostname"
echo "Verify authentication with: glab auth status"
echo ""
echo "GitLab CLI config file location: ~/.config/glab-cli/config.yml"
echo "Edit this file to remove unwanted host configurations if needed"

# Set telemetry to false in GitLab CLI config
GLAB_CONFIG_DIR="$HOME/.config/glab-cli"
GLAB_CONFIG_FILE="$GLAB_CONFIG_DIR/config.yml"

if [ -f "$GLAB_CONFIG_FILE" ]; then
    echo ""
    echo "Setting GitLab CLI telemetry to false..."
    sed -i 's/^telemetry: true$/telemetry: false/' "$GLAB_CONFIG_FILE"
    echo "✓ Telemetry disabled in GitLab CLI configuration"
else
    echo ""
    echo "GitLab CLI config file not found. Telemetry will be set to false on first run."
fi
