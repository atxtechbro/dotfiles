#!/bin/bash

# Ensure glab is configured only for Flywire GitLab instance
# This prevents auth errors when MCP server tries to use glab

set -euo pipefail

GLAB_CONFIG_DIR="$HOME/.config/glab-cli"
GLAB_CONFIG_FILE="$GLAB_CONFIG_DIR/config.yml"

echo "🔧 Hardening glab configuration for Flywire-only access..."

# Ensure config directory exists
mkdir -p "$GLAB_CONFIG_DIR"

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "❌ glab CLI not found. Please install it first."
    exit 1
fi

# Check if we have a Flywire token by looking for it in the auth status output
# We ignore the exit code since it fails due to gitlab.com, but check for Flywire token
AUTH_OUTPUT=$(glab auth status 2>&1 || true)
if ! echo "$AUTH_OUTPUT" | grep -A 10 "gitlab.flywire.tech" | grep -q "Token:"; then
    echo "❌ No valid Flywire GitLab token found."
    echo "Please run: glab auth login --hostname gitlab.flywire.tech"
    exit 1
fi

# Extract the existing Flywire token from current config
EXISTING_TOKEN=""
if [[ -f "$GLAB_CONFIG_FILE" ]]; then
    # Extract token using yq or fallback to grep/sed
    if command -v yq &> /dev/null; then
        EXISTING_TOKEN=$(yq eval '.hosts."gitlab.flywire.tech".token' "$GLAB_CONFIG_FILE" 2>/dev/null || echo "")
    else
        # Fallback: extract token using grep and sed
        EXISTING_TOKEN=$(grep -A 10 "gitlab.flywire.tech:" "$GLAB_CONFIG_FILE" 2>/dev/null | grep "token:" | sed 's/.*token: *"\?\([^"]*\)"\?.*/\1/' || echo "")
    fi
fi

# If no existing token found, try to get it from glab auth status
if [[ -z "$EXISTING_TOKEN" || "$EXISTING_TOKEN" == "null" ]]; then
    echo "❌ Could not extract existing Flywire token from config."
    echo "Please ensure you're authenticated: glab auth login --hostname gitlab.flywire.tech"
    exit 1
fi

# Create a clean config with only Flywire, preserving the existing token
cat > "$GLAB_CONFIG_FILE" << EOF
# What protocol to use when performing Git operations. Supported values: ssh, https.
git_protocol: ssh
# What editor glab should run when creating issues, merge requests, etc. This global config cannot be overridden by hostname.
editor:
# What browser glab should run when opening links. This global config cannot be overridden by hostname.
browser:
# Set your desired Markdown renderer style. Available options are [dark, light, notty]. To set a custom style, refer to https://github.com/charmbracelet/glamour#styles
glamour_style: dark
# Allow glab to automatically check for updates and notify you when there are new updates.
check_update: true
# Whether or not to display hyperlink escape characters when listing items like issues or merge requests. Set to TRUE to display hyperlinks in TTYs only. Force hyperlinks by setting FORCE_HYPERLINKS=1 as an environment variable.
display_hyperlinks: false
# Default GitLab hostname to use - SET TO FLYWIRE FOR MCP SERVER
host: gitlab.flywire.tech
# Set to true (1) to disable prompts, or false (0) to enable them.
no_prompt: false
# Set to false (0) to disable sending usage data to your GitLab instance or true (1) to enable.
# See https://docs.gitlab.com/administration/settings/usage_statistics/
# for more information
telemetry: true
# Configuration specific for GitLab instances.
hosts:
    gitlab.flywire.tech:
        token: "$EXISTING_TOKEN"
        git_protocol: https
        api_protocol: https
EOF

# Set proper permissions
chmod 600 "$GLAB_CONFIG_FILE"

echo "✅ glab configuration hardened for Flywire-only access"

# Verify the configuration
echo "🔍 Verifying glab auth status..."
if glab auth status; then
    echo "✅ glab authentication verified successfully"
else
    echo "❌ glab authentication verification failed"
    exit 1
fi
