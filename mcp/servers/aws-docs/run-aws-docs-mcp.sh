#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"

# Run the server using the full path to the executable
"${VENV_DIR}/bin/awslabs.aws-documentation-mcp-server"
