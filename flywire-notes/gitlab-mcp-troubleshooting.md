# GitLab MCP Server 401 Authentication Issues

## Current Implementation (Updated 2025-07-22)

> **IMPORTANT**: This documentation has been updated to reflect the current implementation using `@zereight/mcp-gitlab` instead of the custom Python implementation.

The GitLab MCP server now uses the external `@zereight/mcp-gitlab` npm package instead of our custom Python implementation. Authentication is handled directly through the `GITLAB_PERSONAL_ACCESS_TOKEN` environment variable in `~/.bash_secrets`.

## Problem
GitLab MCP server connects but returns 401 errors for all tool calls.

## Root Cause Analysis

### Authentication Status Check
```bash
# Check if the token environment variable is set
$ echo $GITLAB_PERSONAL_ACCESS_TOKEN | wc -c
# Should return a number greater than 1
```

**Key Findings:**
1. **Missing or Invalid Token**: The `GITLAB_PERSONAL_ACCESS_TOKEN` environment variable is either not set or contains an invalid/revoked token.
2. **Token Permissions**: The token may not have the required scopes (api, read_user, read_repository, write_repository).

## Resolution Steps

### 1. Generate New Personal Access Token
1. Go to https://gitlab.flywire.tech/-/profile/personal_access_tokens
2. Create new token with scopes: `api`, `read_user`, `read_repository`, `write_repository`
3. Set expiration date (recommended: 1 year)
4. Name it descriptively (e.g., "MCP Server - 2025-07-22")

### 2. Update Environment Variable
Add or update the token in your `~/.bash_secrets` file:

```bash
# GitLab MCP server authentication
export GITLAB_PERSONAL_ACCESS_TOKEN="glpat-your-new-token-here"
```

### 3. Reload Environment Variables
```bash
source ~/.bash_secrets
```

### 4. Test MCP Server
```bash
# Test a simple GitLab MCP tool call
claude "List GitLab projects"
```

## Architecture Notes

### Current MCP Server Chain
1. **MCP Client** (Claude/Amazon Q) → 
2. **gitlab-mcp-wrapper.sh** → 
3. **@zereight/mcp-gitlab** (Node.js package) → 
4. **GitLab API**

The 401 error occurs at step 4 (GitLab API) due to missing or invalid token.

### Authentication Flow
- MCP server uses `GITLAB_PERSONAL_ACCESS_TOKEN` environment variable directly
- No dependency on `glab` CLI for authentication

## Prevention
- Monitor token expiration dates
- Set up token rotation reminders
- Consider using application tokens instead of personal access tokens for better lifecycle management

## Related Files
- MCP Config: `/Users/morgan.joyce/ppv/pillars/dotfiles/mcp/mcp.json`
- Wrapper Script: `/Users/morgan.joyce/ppv/pillars/dotfiles/mcp/gitlab-mcp-wrapper.sh`
- Secrets: `~/.bash_secrets` (contains `GITLAB_PERSONAL_ACCESS_TOKEN`)

## COMPLETE RESOLUTION STEPS (Spilled Coffee Ready)

### Prerequisites
- `WORK_MACHINE="true"` in `~/.bash_exports.local`
- Node.js installed (via NVM or system package)

### Step 1: Install External GitLab MCP Server
```bash
# Install the external GitLab MCP server
npm install -g @zereight/mcp-gitlab
```

### Step 2: Configure GitLab Token
```bash
# Add to ~/.bash_secrets
echo 'export GITLAB_PERSONAL_ACCESS_TOKEN="glpat-your-new-token-here"' >> ~/.bash_secrets

# Make the token available in current session
source ~/.bash_secrets
```

### Step 3: Test MCP Server
```bash
# This should return your user info without 401 errors
claude "Get my GitLab user info"
```

## Root Cause Summary
1. **Missing/Invalid Token**: `GITLAB_PERSONAL_ACCESS_TOKEN` environment variable not set or contains invalid token
2. **Token Permissions**: Token may not have required scopes

## Key Learnings

### Architecture Understanding
- **Simplified Chain**: Claude → gitlab-mcp-wrapper.sh → @zereight/mcp-gitlab → GitLab API
- **Direct Authentication**: Environment variable used directly, no intermediate CLI tools
- **Work Machine Only**: GitLab MCP server only available when `WORK_MACHINE="true"`

### Prevention Strategies
- Monitor token expiration (set calendar reminder)
- Use descriptive token names with dates for tracking
- Keep backup authentication method documented
- Regular MCP server health checks

This troubleshooting guide reflects the current implementation using the external `@zereight/mcp-gitlab` package, which simplifies authentication and maintenance compared to the previous custom implementation.
