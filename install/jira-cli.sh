#!/bin/bash

# Define variables
VERSION="1.5.2"
INSTALL_DIR="$HOME/.local/bin"
TEMP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Determine architecture
if [ "$ARCH" = "x86_64" ]; then
    ARCH="x86_64"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download and install
echo "Installing jira-cli v$VERSION..."
cd "$TEMP_DIR"
curl -L "https://github.com/ankitpokhrel/jira-cli/releases/download/v$VERSION/jira_${VERSION}_${OS}_${ARCH}.tar.gz" -o jira.tar.gz
tar -xzf jira.tar.gz
mkdir -p "$INSTALL_DIR"
cp bin/jira "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/jira"

# Clean up
rm -rf "$TEMP_DIR"
echo "jira-cli v$VERSION installed to $INSTALL_DIR/jira"
