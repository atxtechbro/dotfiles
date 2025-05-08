#!/bin/bash

# Setup script for AWS Documentation MCP Server using uv
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "uv is not installed. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for this session
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Create virtual environment if it doesn't exist
if [ ! -d "${VENV_DIR}" ]; then
    echo "Creating virtual environment with uv..."
    uv venv "${VENV_DIR}"
fi

# Install or upgrade the AWS Documentation MCP server
echo "Installing AWS Documentation MCP server with uv..."
uv pip install --python "${VENV_DIR}/bin/python" awslabs.aws-documentation-mcp-server

# Create a wrapper script to run the server
cat > "${SCRIPT_DIR}/run-aws-docs-mcp.sh" << 'EOF'
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Run the server
aws-documentation-mcp-server
EOF

# Make the wrapper script executable
chmod +x "${SCRIPT_DIR}/run-aws-docs-mcp.sh"

echo "AWS Documentation MCP server setup complete!"
