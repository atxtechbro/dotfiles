#!/bin/bash

# Setup script for atlassian-mcp-server
# This script sets up the Python environment for the forked mcp-atlassian server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up atlassian-mcp-server..."

# Find Python 3.10 or higher
PYTHON_CMD=""
for python_version in python3.12 python3.11 python3.10; do
    if command -v $python_version &> /dev/null; then
        PYTHON_CMD=$python_version
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "Error: Python 3.10 or higher is required."
    echo "Please install Python 3.10+ and try again."
    exit 1
fi

echo "Using $PYTHON_CMD (version $($PYTHON_CMD --version))"

# Create virtual environment if it doesn't exist
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON_CMD -m venv "$SCRIPT_DIR/.venv"
fi

# Activate virtual environment
source "$SCRIPT_DIR/.venv/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install the package in development mode
echo "Installing atlassian-mcp-server in development mode..."
pip install -e "$SCRIPT_DIR"

echo "Setup complete! The server is ready to use."
echo "To run manually: source $SCRIPT_DIR/.venv/bin/activate && python -m mcp_atlassian"