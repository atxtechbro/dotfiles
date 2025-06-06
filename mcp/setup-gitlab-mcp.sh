#!/bin/bash

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# Check if glab CLI is already installed
if ! command -v glab &> /dev/null; then
    echo "GitLab CLI (glab) not found. Installing..."
    
    # Determine OS and architecture
    OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m)"
    
    # Map architecture to GitLab CLI naming convention
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="arm"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Create a temporary directory for download
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Get the latest release version
    echo "Fetching latest GitLab CLI release..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/gl-cli/glab/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Failed to determine latest GitLab CLI version"
        exit 1
    fi
    
    echo "Latest version: $LATEST_VERSION"
    
    # Download the appropriate binary
    DOWNLOAD_URL="https://github.com/gl-cli/glab/releases/download/v${LATEST_VERSION}/glab_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"
    echo "Downloading from: $DOWNLOAD_URL"
    
    curl -L "$DOWNLOAD_URL" -o glab.tar.gz
    
    # Extract the archive
    tar -xzf glab.tar.gz
    
    # Install the binary
    mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers/bin"
    cp bin/glab "$CURRENT_SCRIPT_DIRECTORY/servers/bin/"
    chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/bin/glab"
    
    # Create symlink in a directory that's in PATH
    mkdir -p "$HOME/.local/bin"
    ln -sf "$CURRENT_SCRIPT_DIRECTORY/servers/bin/glab" "$HOME/.local/bin/glab"
    
    # Clean up
    cd "$CURRENT_SCRIPT_DIRECTORY"
    rm -rf "$TMP_DIR"
    
    echo "GitLab CLI installed successfully at $CURRENT_SCRIPT_DIRECTORY/servers/bin/glab"
    echo "A symlink has been created at $HOME/.local/bin/glab"
    
    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "Please add $HOME/.local/bin to your PATH by adding the following line to your .bashrc or .zshrc:"
        echo 'export PATH="$HOME/.local/bin:$PATH"'
        echo "Then restart your terminal or run 'source ~/.bashrc' (or 'source ~/.zshrc')"
    fi
else
    echo "GitLab CLI (glab) is already installed"
fi

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

echo "GitLab MCP server setup complete!"
echo "The server will use your GitLab CLI authentication token."
echo "Make sure you're logged in with 'glab auth login' before using the GitLab MCP server."
echo "Alternatively, you can set GITLAB_PERSONAL_ACCESS_TOKEN in your ~/.bash_secrets file."
