#!/bin/bash

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

# Check if jira is already installed
if [ -f "$JIRA_BIN" ]; then
    INSTALLED_VERSION=$("$JIRA_BIN" version 2>/dev/null | grep -o 'Version="[^"]*"' | cut -d'"' -f2)
    if [ "$INSTALLED_VERSION" = "$VERSION" ]; then
        echo "jira-cli v$VERSION is already installed at $JIRA_BIN"
        # IMPORTANT: When a script is sourced (using 'source' or '.'), 'exit' will terminate the parent shell
        # This pattern tries 'return' first (works when sourced) and falls back to 'exit' (when run directly)
        # This allows the script to work both when sourced from install-tools.sh and when executed directly
        return 0 2>/dev/null || exit 0
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
    # Same pattern as above for error case
    return 1 2>/dev/null || exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"
