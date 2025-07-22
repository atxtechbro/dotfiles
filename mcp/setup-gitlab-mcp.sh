#!/bin/bash

# Setup script for external GitLab MCP server

set -e

echo "Setting up external GitLab MCP server..."

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi

# Install the external GitLab MCP server
echo "Installing @zereight/mcp-gitlab..."
npm install -g @zereight/mcp-gitlab

# Verify installation
if command -v mcp-gitlab &> /dev/null; then
    echo "✓ External GitLab MCP server installed successfully"
else
    echo "✗ GitLab MCP server installation failed"
    exit 1
fi

echo "GitLab MCP server setup complete!"
echo "The external server provides comprehensive GitLab API integration including:"
echo "  - Repository management"
echo "  - Issue tracking"
echo "  - Merge request operations"
echo "  - Pipeline and job management"
echo "  - Wiki operations"
echo "  - User and group management"
echo ""
echo "Authentication is handled via GITLAB_PERSONAL_ACCESS_TOKEN environment variable."
echo "Make sure this is set in your ~/.bash_secrets file."