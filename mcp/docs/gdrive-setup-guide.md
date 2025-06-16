# Google Drive MCP Server Setup Guide

This guide provides a complete, reproducible setup for the Google Drive MCP server following our **Spilled Coffee Principle**.

## Prerequisites

- Docker installed and running
- `jq` command-line JSON processor (`brew install jq`)
- Google Cloud Console access

## Quick Setup

```bash
# Run the automated setup script
cd ~/ppv/pillars/dotfiles/mcp
./setup-gdrive-credentials.sh
```

## Manual Setup (if needed)

### 1. Create OAuth Credentials

1. Go to [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select existing one
3. Enable the Google Drive API
4. Create OAuth 2.0 Client ID:
   - Application type: Desktop application
   - Name: "Google Drive MCP Server"
5. Download the JSON file to `~/tmp/gdrive-oauth/credentials.json`

### 2. Run Setup Script

The setup script will:
- Generate OAuth authorization URL
- Guide you through the authorization flow
- Exchange authorization code for refresh token
- Set up Docker volume with credentials
- Update your `.bash_secrets` file
- Test the complete setup

## File Locations

After setup, credentials are stored in:
- **Local**: `~/.config/gdrive/credentials.json` (secure permissions)
- **Docker Volume**: `mcp-gdrive` volume (for MCP server)
- **Environment**: `GDRIVE_CREDENTIALS_PATH` in `.bash_secrets`

## Troubleshooting

### "Invalid Grant" Error
- Authorization codes expire in ~10 minutes
- Generate a fresh OAuth URL and try again quickly

### Docker Volume Issues
```bash
# Recreate the Docker volume
docker volume rm mcp-gdrive
./setup-gdrive-credentials.sh
```

### MCP Server Not Loading
```bash
# Test the Docker container directly
docker run --rm -v mcp-gdrive:/gdrive-server -e GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json mcp/gdrive echo "Test"
```

## Security Notes

- Credentials files have `600` permissions (owner read/write only)
- Refresh tokens allow long-term access - keep them secure
- The setup uses read-only Google Drive scope for safety

## Following Our Principles

This setup follows our core principles:

- **Spilled Coffee Principle**: Complete automation - run one script and be operational
- **Snowball Method**: Reusable OAuth utilities for future Google service integrations
- **Versioning Mindset**: Iterative improvements to the setup process
