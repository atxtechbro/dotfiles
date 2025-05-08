#!/bin/bash

# Setup script for AWS Documentation MCP Server
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"

# Create virtual environment if it doesn't exist
if [ ! -d "${VENV_DIR}" ]; then
    python3 -m venv "${VENV_DIR}"
fi

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Install or upgrade the AWS Documentation MCP server
pip install --upgrade awslabs.aws-documentation-mcp-server

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
