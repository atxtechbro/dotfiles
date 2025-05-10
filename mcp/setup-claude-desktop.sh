#!/bin/bash
# Setup script for Claude Desktop Debian MCP client
# DEPENDENCIES: nodejs, npm, icoutils
# Install with: sudo apt-get install -y nodejs npm icoutils

set -e

# Clone this repository
git clone https://github.com/aaddrick/claude-desktop-debian.git
cd claude-desktop-debian

# Build the package (Defaults to .deb and cleans build files)
./build.sh

echo "Note: After installation, you may need to quit and restart the application from the system tray for it to work properly the first time."
