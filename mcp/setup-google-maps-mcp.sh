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

# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

echo "Setting up Google Maps MCP server..."

# Check prerequisites
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)

# Setup MCP servers repository
setup_mcp_servers_repo

# Build Docker image
build_mcp_docker_image "google-maps"

# Update secrets template
update_secrets_template \
  "$REPO_ROOT" \
  "GOOGLE_MAPS_API_KEY" \
  "GOOGLE MAPS API CREDENTIALS" \
  "Get API key from: https://developers.google.com/maps/documentation/javascript/get-api-key" \
  "export GOOGLE_MAPS_API_KEY=\"your_api_key\""

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

# Print setup completion message
print_setup_complete \
  "Google Maps" \
  "   export GOOGLE_MAPS_API_KEY=\"your_api_key\"" \
  "- maps_geocode: Convert address to coordinates
- maps_reverse_geocode: Convert coordinates to address
- maps_search_places: Search for places using text query
- maps_place_details: Get detailed information about a place
- maps_distance_matrix: Calculate distances and times between points
- maps_elevation: Get elevation data for locations
- maps_directions: Get directions between points"
