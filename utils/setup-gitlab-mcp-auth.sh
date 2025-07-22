#!/bin/bash

# =========================================================
# GITLAB MCP AUTHENTICATION SETUP
# =========================================================
# PURPOSE: Automate GitLab MCP server authentication setup
# PRINCIPLE: Spilled Coffee - destroy machine, operational that afternoon
# =========================================================

set -e

echo "🔧 Setting up GitLab MCP authentication..."

# Check if this is a work machine
if [[ "$WORK_MACHINE" != "true" ]]; then
    echo "⚠️  GitLab MCP only available on work machines"
    echo "   Set WORK_MACHINE=true in ~/.bash_exports.local to enable"
    exit 0
fi

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "❌ glab CLI not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install glab
    else
        echo "❌ Please install glab CLI: https://gitlab.com/gitlab-org/cli"
        exit 1
    fi
fi

# Check current authentication status
echo "🔍 Checking GitLab authentication..."
if glab auth status --host gitlab.flywire.tech >/dev/null 2>&1; then
    echo "✅ GitLab authentication already configured"
else
    echo "🔑 GitLab authentication needed"
    echo ""
    echo "📋 Steps to get token:"
    echo "   1. Go to: https://gitlab.flywire.tech/-/profile/personal_access_tokens"
    echo "   2. Click 'Add new token'"
    echo "   3. Name: 'MCP Server - $(date +%Y-%m-%d)'"
    echo "   4. Scopes: api, read_user, read_repository, write_repository"
    echo "   5. Expiration: 1 year from now"
    echo ""
    
    # Check if we're in an interactive environment
    if [[ -t 0 ]]; then
        read -p "Enter GitLab token: " GITLAB_TOKEN
        if [[ -n "$GITLAB_TOKEN" ]]; then
            glab config set token "$GITLAB_TOKEN" --host gitlab.flywire.tech
            echo "✅ Token configured"
        else
            echo "❌ No token provided"
            exit 1
        fi
    else
        echo "❌ Non-interactive environment - manual token setup required"
        echo "   Run: glab config set token <YOUR_TOKEN> --host gitlab.flywire.tech"
        exit 1
    fi
fi

# Set correct default host (critical for MCP server)
echo "🎯 Setting default GitLab host to flywire.tech..."
glab config set host gitlab.flywire.tech

# Verify authentication
echo "🧪 Testing GitLab MCP server..."
if glab auth status --host gitlab.flywire.tech >/dev/null 2>&1; then
    echo "✅ GitLab MCP authentication ready"
    echo ""
    echo "🚀 Test with: claude 'Get my GitLab user info'"
else
    echo "❌ GitLab authentication failed"
    exit 1
fi
