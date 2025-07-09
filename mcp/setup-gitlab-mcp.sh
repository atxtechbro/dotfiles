#!/bin/bash

# Setup script for GitLab MCP server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITLAB_MCP_DIR="${SCRIPT_DIR}/servers/gitlab-mcp-server"

echo "Setting up GitLab MCP server..."

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "Error: glab CLI is not installed. Please install it first:"
    echo "  macOS: brew install glab"
    echo "  Linux: See https://gitlab.com/gitlab-org/cli/-/releases"
    exit 1
fi

# Check if glab is authenticated (warning only, not failure)
if ! glab auth status &> /dev/null; then
    echo "Warning: glab authentication may not be configured for all instances."
    echo "If you need to authenticate, run: glab auth login"
    echo "Continuing with setup..."
else
    echo "✓ glab CLI is installed and authenticated"
fi

# Navigate to the GitLab MCP server directory
cd "${GITLAB_MCP_DIR}"

# Create virtual environment using uv
echo "Setting up Python environment..."
if command -v uv &> /dev/null; then
    if [ ! -d ".venv" ]; then
        uv venv
    fi
    
    # Install the package in development mode
    uv pip install -e .
    echo "✓ GitLab MCP server installed with uv"
else
    echo "Warning: uv not found, falling back to pip"
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
    fi
    
    source .venv/bin/activate
    pip install -e .
    echo "✓ GitLab MCP server installed with pip"
fi

# Make the main module executable
chmod +x src/gitlab_mcp_server/__main__.py

# Test the server
echo "Testing GitLab MCP server..."
if (echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version": "1.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | .venv/bin/python -m gitlab_mcp_server | grep -q "gitlab_get_job_log"; then
    echo "✓ GitLab MCP server is working correctly"
else
    echo "✗ GitLab MCP server test failed"
    exit 1
fi

echo "GitLab MCP server setup complete!"
echo "The server provides pipeline debugging capabilities including:"
echo "  - List pipelines and jobs"
echo "  - Get job logs (critical for debugging)"
echo "  - Get failed jobs with logs"
echo "  - Retry failed jobs"
echo "  - Cancel pipelines"
echo ""
echo "Use 'gitlab_get_failed_jobs' to get all failed jobs with logs from a pipeline."
echo "Use 'gitlab_get_job_log' to get logs for a specific job."