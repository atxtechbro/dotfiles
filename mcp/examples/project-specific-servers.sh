#!/bin/bash

# =========================================================
# PROJECT-SPECIFIC MCP SERVER MANAGEMENT
# =========================================================
# PURPOSE: Example script showing how to enable/disable MCP servers
# based on project type detection
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source MCP environment utilities
source "$DOTFILES_DIR/utils/mcp-environment.sh"

# Default MCP config file location
MCP_CONFIG_FILE="$DOTFILES_DIR/mcp/mcp.json"

# Function to detect project type and enable appropriate servers
detect_project_type() {
  local project_dir="$1"
  local enabled_servers=()
  local disabled_servers=()
  
  echo "Detecting project type in: $project_dir"
  
  # Node.js project detection
  if [[ -f "$project_dir/package.json" ]]; then
    echo "Detected Node.js project"
    enabled_servers+=("nodejs-server")
    
    # Check for specific frameworks
    if grep -q "\"react\"" "$project_dir/package.json"; then
      echo "Detected React framework"
      enabled_servers+=("react-server")
    fi
    
    if grep -q "\"vue\"" "$project_dir/package.json"; then
      echo "Detected Vue framework"
      enabled_servers+=("vue-server")
    fi
  else
    # Disable Node.js related servers if not a Node.js project
    disabled_servers+=("nodejs-server" "react-server" "vue-server")
  fi
  
  # Python project detection
  if [[ -f "$project_dir/requirements.txt" || -f "$project_dir/pyproject.toml" ]]; then
    echo "Detected Python project"
    enabled_servers+=("python-server")
    
    # Check for specific frameworks
    if grep -q "django" "$project_dir/requirements.txt" 2>/dev/null; then
      echo "Detected Django framework"
      enabled_servers+=("django-server")
    fi
    
    if grep -q "flask" "$project_dir/requirements.txt" 2>/dev/null; then
      echo "Detected Flask framework"
      enabled_servers+=("flask-server")
    fi
  else
    # Disable Python related servers if not a Python project
    disabled_servers+=("python-server" "django-server" "flask-server")
  fi
  
  # Java project detection
  if [[ -f "$project_dir/pom.xml" || -f "$project_dir/build.gradle" ]]; then
    echo "Detected Java project"
    enabled_servers+=("java-server")
    
    # Check for specific frameworks
    if grep -q "spring-boot" "$project_dir/pom.xml" 2>/dev/null; then
      echo "Detected Spring Boot framework"
      enabled_servers+=("spring-server")
    fi
  else
    # Disable Java related servers if not a Java project
    disabled_servers+=("java-server" "spring-server")
  fi
  
  # Enable detected servers
  if [[ ${#enabled_servers[@]} -gt 0 ]]; then
    echo "Enabling servers for detected project type: ${enabled_servers[*]}"
    enable_mcp_servers "$MCP_CONFIG_FILE" "${enabled_servers[@]}"
  fi
  
  # Disable irrelevant servers
  if [[ ${#disabled_servers[@]} -gt 0 ]]; then
    echo "Disabling irrelevant servers: ${disabled_servers[*]}"
    disable_mcp_servers "$MCP_CONFIG_FILE" "${disabled_servers[@]}"
  fi
  
  echo "Project-specific MCP server configuration complete"
  echo "Restart Amazon Q for changes to take effect"
}

# Show usage information
show_usage() {
  echo "Usage: project-specific-servers.sh [project_directory]"
  echo ""
  echo "Configure MCP servers based on project type detection"
  echo ""
  echo "If no project directory is specified, the current directory is used"
  echo ""
  echo "Examples:"
  echo "  project-specific-servers.sh                  # Use current directory"
  echo "  project-specific-servers.sh ~/projects/myapp # Use specified directory"
}

# Parse command line arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

# Use specified directory or current directory
project_dir="${1:-.}"

# Check if directory exists
if [[ ! -d "$project_dir" ]]; then
  echo "Error: Directory not found: $project_dir"
  exit 1
fi

# Detect project type and configure servers
detect_project_type "$project_dir"