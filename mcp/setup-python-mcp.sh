#!/bin/bash
# Python MCP Server setup script
# Following the Spilled Coffee Principle: anyone should be able to destroy their machine
# and be fully operational again that afternoon.

set -e

# Ensure directory exists
mkdir -p "$HOME/ppv/pillars/dotfiles/mcp"

# Ensure uv is installed
if ! command -v uv &> /dev/null; then
    echo "Installing uv package manager..."
    curl -sSf https://install.python-uv.org | sh
fi

# Clone the repository (using the enhanced fork with .env support and additional tools)
REPO_DIR="$HOME/ppv/pillars/dotfiles/mcp/mcp-python"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning mcp-python repository..."
    git clone https://github.com/piplin-es/mcp-python.git "$REPO_DIR"
else
    echo "Repository already exists, updating..."
    cd "$REPO_DIR"
    git pull
fi

# Install dependencies
cd "$REPO_DIR"
echo "Installing dependencies..."
uv pip install -e .

# Create a wrapper script for easy starting
WRAPPER_SCRIPT="$HOME/ppv/pillars/dotfiles/mcp/py-mcp-start"
cat > "$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash
# Start the Python MCP server
# This script follows the Snowball Method principle by maintaining persistent context

cd "$HOME/ppv/pillars/dotfiles/mcp/mcp-python"
uv run mcp_python
EOF

# Make the wrapper script executable
chmod +x "$WRAPPER_SCRIPT"

# Create a symlink to the wrapper script in a directory in PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$WRAPPER_SCRIPT" "$HOME/.local/bin/py-mcp-start"

# Create a sample .env file template if it doesn't exist
ENV_EXAMPLE="$REPO_DIR/.env.example"
if [ ! -f "$ENV_EXAMPLE" ]; then
    echo "Creating .env.example template..."
    cat > "$ENV_EXAMPLE" << 'EOF'
# Python MCP Server Environment Variables
# Copy this file to .env and customize as needed

# API Keys (if needed by your Python scripts)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Project Settings
PROJECTS_ROOT=$HOME/projects
EOF
fi

# Create logs directory
mkdir -p "$REPO_DIR/logs"

echo "Python MCP server setup complete!"
echo "To start the server, run: py-mcp-start"
echo "To configure your MCP client, see the README-python-mcp.md file"
