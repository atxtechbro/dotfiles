#!/bin/bash
#
# install-mcp-shell.sh - Installs the sonirico/mcp-shell server
#
# This script follows the "spilled coffee" principle - it ensures the MCP shell server
# is available without manual intervention, making your environment fully operational
# after a fresh setup.
#
# Usage: ./utils/install-mcp-shell.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$REPO_ROOT/mcp/config"
MCP_SHELL_DIR="$REPO_ROOT/mcp/mcp-shell"
CONFIG_FILE="$CONFIG_DIR/mcp-shell.yaml"

echo "Installing sonirico/mcp-shell server..."

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is required but not installed. Installing Go first..."
    "$SCRIPT_DIR/install-go.sh"
fi

# Create directories if they don't exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$MCP_SHELL_DIR"

# Clone or update the repository
if [ -d "$MCP_SHELL_DIR/.git" ]; then
    echo "Updating existing mcp-shell repository..."
    cd "$MCP_SHELL_DIR"
    git pull origin main
else
    echo "Cloning mcp-shell repository..."
    git clone https://github.com/sonirico/mcp-shell.git "$MCP_SHELL_DIR"
    cd "$MCP_SHELL_DIR"
fi

# Build the server
echo "Building mcp-shell server..."
go build -o mcp-shell

# Create default configuration if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default security configuration..."
    cat > "$CONFIG_FILE" << 'EOF'
# MCP Shell Security Configuration
# This configuration provides a balanced approach to security while allowing
# power users to perform common operations safely.

security:
  enabled: true
  
  # Commands explicitly allowed (whitelist approach)
  allowed_commands:
    # File operations
    - ls
    - cat
    - grep
    - find
    - echo
    - mkdir
    - touch
    - cp
    - mv
    - rm
    - ln
    - chmod
    - chown
    - tar
    - zip
    - unzip
    - gzip
    - gunzip
    
    # Navigation and information
    - cd
    - pwd
    - df
    - du
    - free
    - top
    - ps
    - kill
    - which
    - whereis
    - type
    
    # Text processing
    - head
    - tail
    - less
    - more
    - sort
    - uniq
    - wc
    - sed
    - awk
    - cut
    - tr
    
    # Network tools
    - ping
    - curl
    - wget
    - ssh
    - scp
    - netstat
    - ifconfig
    - ip
    
    # Development tools
    - git
    - npm
    - node
    - python
    - pip
    - go
    - make
    - gcc
    - g++
    
    # Package management (distro-specific)
    - apt
    - apt-get
    - yum
    - dnf
    - pacman
    - brew
    
    # AWS CLI
    - aws
    
    # Docker
    - docker
    - docker-compose
    
    # Kubernetes
    - kubectl
    - helm
  
  # Commands explicitly blocked (blacklist approach)
  blocked_commands:
    - rm -rf /
    - rm -rf /*
    - sudo rm -rf
    - :(){ :|:& };:  # Fork bomb
    - dd if=/dev/random
    - chmod -R 777 /
    - chown -R / 
    - mkfs
    
  # Regex patterns to block potentially dangerous commands
  blocked_patterns:
    - 'rm\s+-rf\s+/(?!tmp|home)'  # Block rm -rf / but allow rm -rf /tmp
    - '>\s+/dev/(sd|hd|nvme|xvd)'  # Block writing to block devices
    - 'dd\s+.*if=/dev/(zero|random).*of=/dev/(sd|hd|nvme|xvd)'  # Block overwriting disks
    - ':\(\)\s*{\s*:\s*\|\s*:\s*(&|;)\s*}\s*;:'  # Fork bomb pattern
  
  # Execution limits
  max_execution_time: 60s  # Generous timeout for longer operations
  max_output_size: 5242880  # 5MB output limit
  
  # Working directory restrictions
  # This allows operations in common user directories but prevents
  # access to system directories
  allowed_working_directories:
    - /home
    - /tmp
    - /var/tmp
    - /opt
    - /usr/local
  
  # Security auditing
  audit_log: true
  audit_log_path: ~/.mcp-shell-audit.log
EOF
fi

echo "Creating wrapper script..."
WRAPPER_SCRIPT="$REPO_ROOT/mcp/mcp-shell-wrapper.sh"
cat > "$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash
#
# mcp-shell-wrapper.sh - Wrapper script for the sonirico/mcp-shell server
#
# This script starts the mcp-shell server with the appropriate configuration.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/mcp-shell.yaml"
MCP_SHELL_BIN="$SCRIPT_DIR/mcp-shell/mcp-shell"

# Check if the binary exists
if [ ! -f "$MCP_SHELL_BIN" ]; then
    echo "Error: mcp-shell binary not found at $MCP_SHELL_BIN"
    echo "Please run utils/install-mcp-shell.sh first"
    exit 1
fi

# Start the server with the configuration file
exec "$MCP_SHELL_BIN" --config "$CONFIG_FILE" "$@"
EOF

chmod +x "$WRAPPER_SCRIPT"

echo "Creating setup script..."
SETUP_SCRIPT="$REPO_ROOT/mcp/setup-mcp-shell.sh"
cat > "$SETUP_SCRIPT" << 'EOF'
#!/bin/bash
#
# setup-mcp-shell.sh - Sets up the mcp-shell server for use with Amazon Q CLI
#
# This script registers the mcp-shell server with Amazon Q CLI.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SCRIPT="$SCRIPT_DIR/mcp-shell-wrapper.sh"

# Check if Amazon Q CLI is installed
if ! command -v q &> /dev/null; then
    echo "Error: Amazon Q CLI not found"
    echo "Please install Amazon Q CLI first"
    exit 1
fi

# Register the MCP server with Amazon Q CLI
echo "Registering mcp-shell server with Amazon Q CLI..."
q mcp register --name mcp-shell --path "$WRAPPER_SCRIPT"

echo "MCP shell server registered successfully!"
echo "You can now use it with Amazon Q CLI by running: q chat"
EOF

chmod +x "$SETUP_SCRIPT"

echo "Installation complete!"
echo "To set up the MCP shell server with Amazon Q CLI, run:"
echo "  ./mcp/setup-mcp-shell.sh"