#!/bin/bash

# =========================================================
# GOOGLE MAPS MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Google Maps MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The google-maps-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

echo "Setting up Google Maps MCP server..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first." >&2
    exit 1
fi

# Check if we're in the dotfiles repository
if [ ! -d "$(dirname "$0")/../.git" ]; then
    echo "Error: This script must be run from the dotfiles repository." >&2
    exit 1
fi

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Clone the MCP servers repository if it doesn't exist
if [ ! -d "/tmp/mcp-servers" ]; then
    echo "Cloning MCP servers repository..."
    git clone https://github.com/modelcontextprotocol/servers.git /tmp/mcp-servers
else
    echo "Updating MCP servers repository..."
    cd /tmp/mcp-servers && git pull
fi

# Build the Docker image
echo "Building Docker image for Google Maps MCP server..."
cd /tmp/mcp-servers && docker build -t mcp/google-maps -f src/google-maps/Dockerfile .

# Update mcp.json to include the Google Maps MCP server
echo "Updating mcp.json configuration..."
MCP_JSON="$REPO_ROOT/mcp/mcp.json"

# Check if google-maps entry already exists in mcp.json
if grep -q "google-maps" "$MCP_JSON"; then
    echo "Google Maps MCP server already configured in mcp.json"
else
    # Create a backup of the current mcp.json
    cp "$MCP_JSON" "$MCP_JSON.bak"
    
    # Insert the google-maps configuration before the last closing brace
    sed -i '/"mcpServers": {/a \
    "google-maps": {\
      "command": "google-maps-mcp-wrapper.sh",\
      "args": [],\
      "env": {\
        "FASTMCP_LOG_LEVEL": "ERROR"\
      }\
    },' "$MCP_JSON"
    
    echo "Added Google Maps MCP server configuration to mcp.json"
fi

# Update .bash_secrets.example if needed
SECRETS_EXAMPLE="$REPO_ROOT/.bash_secrets.example"
if ! grep -q "GOOGLE_MAPS_API_KEY" "$SECRETS_EXAMPLE"; then
    echo "" >> "$SECRETS_EXAMPLE"
    echo "# ==== GOOGLE MAPS API CREDENTIALS ====" >> "$SECRETS_EXAMPLE"
    echo "# Get API key from: https://developers.google.com/maps/documentation/javascript/get-api-key" >> "$SECRETS_EXAMPLE"
    echo "# export GOOGLE_MAPS_API_KEY=\"your_api_key\"" >> "$SECRETS_EXAMPLE"
    
    echo "Updated .bash_secrets.example with Google Maps API key template"
fi

echo ""
echo "Setup complete! To use the Google Maps MCP server:"
echo "1. Add your Google Maps API key to ~/.bash_secrets:"
echo "   export GOOGLE_MAPS_API_KEY=\"your_api_key\""
echo "2. Restart your Amazon Q CLI or other MCP client"
echo ""
echo "The Google Maps MCP server provides these tools:"
echo "- maps_geocode: Convert address to coordinates"
echo "- maps_reverse_geocode: Convert coordinates to address"
echo "- maps_search_places: Search for places using text query"
echo "- maps_place_details: Get detailed information about a place"
echo "- maps_distance_matrix: Calculate distances and times between points"
echo "- maps_elevation: Get elevation data for locations"
echo "- maps_directions: Get directions between points"
