#!/bin/bash

# Simple installation script for jira-cli

# Define variables
VERSION="1.5.2"
INSTALL_DIR="$HOME/.local/bin"
TEMP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
JIRA_BIN="$INSTALL_DIR/jira"

# Determine architecture
if [ "$ARCH" = "x86_64" ]; then
    ARCH="x86_64"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Check if jira is already installed
if [ -f "$JIRA_BIN" ]; then
    INSTALLED_VERSION=$("$JIRA_BIN" version 2>/dev/null | grep -o 'Version="[^"]*"' | cut -d'"' -f2)
    if [ "$INSTALLED_VERSION" = "$VERSION" ]; then
        echo "jira-cli v$VERSION is already installed at $JIRA_BIN"
        exit 0
    else
        echo "Updating jira-cli from v$INSTALLED_VERSION to v$VERSION..."
    fi
elif [ -d "$JIRA_BIN" ]; then
    echo "Warning: $JIRA_BIN exists as a directory. Removing it to continue."
    rm -rf "$JIRA_BIN"
fi

# Download and install
echo "Installing jira-cli v$VERSION..."
cd "$TEMP_DIR"
curl -s -L "https://github.com/ankitpokhrel/jira-cli/releases/download/v$VERSION/jira_${VERSION}_${OS}_${ARCH}.tar.gz" -o jira.tar.gz
tar -xzf jira.tar.gz

# The tarball has a nested directory structure
EXTRACT_DIR="jira_${VERSION}_${OS}_${ARCH}"
if [ -d "$EXTRACT_DIR" ]; then
    cp "$EXTRACT_DIR/bin/jira" "$JIRA_BIN"
    chmod +x "$JIRA_BIN"
    echo "jira-cli v$VERSION installed to $JIRA_BIN"
else
    echo "Error: Expected directory structure not found in tarball"
    ls -la
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"

echo "Installation complete. Make sure $INSTALL_DIR is in your PATH."
echo "You can add it by running: export PATH=\"$INSTALL_DIR:\$PATH\""
