# MCP Server Connectivity Issue Fix

## Issue Summary

**Problem**: MCP server connections were inconsistent, with only Playwright connecting successfully while other servers (Git, GitHub, Brave Search) failed to connect.

**Root Cause**: Missing setup dependencies and configuration for non-Playwright MCP servers in the GitHub Actions environment.

## Investigation Results

### Working Server
- **Playwright MCP**: ✅ Working
  - Uses direct NPM package execution (`npx @playwright/mcp@latest`)
  - No local setup required - runs directly from NPM registry

### Failing Servers and Root Causes

#### 1. Git MCP Server ❌
- **Issue**: Missing Python virtual environment
- **Root Cause**: `.venv` directory not found at `mcp/servers/git-mcp-server/.venv`
- **Fix Applied**: 
  - Installed `uv` package manager: `pip install uv`
  - Ran `./setup-git-mcp.sh` to create Python virtual environment
  - Installed dependencies from `pyproject.toml`

#### 2. GitHub MCP Server ❌
- **Issue**: Binary not built 
- **Root Cause**: No compiled binary at `mcp/servers/github`
- **Fix Applied**:
  - Ran `./setup-github-mcp.sh` to build Go binary
  - Successfully compiled from in-house source code
  - **Note**: Still requires GitHub CLI authentication (`gh auth login`)

#### 3. Brave Search MCP Server ❌
- **Issue**: Missing API credentials configuration
- **Root Cause**: No `~/.bash_secrets` file containing `BRAVE_API_KEY`
- **Fix Applied**:
  - Ran `./setup-brave-search-mcp.sh`
  - **Note**: Still requires API key configuration from https://api.search.brave.com/app/keys

#### 4. Health Check Script Bug ❌
- **Issue**: JSON parsing incorrectly extracted all keys instead of just server names
- **Root Cause**: Regex pattern picked up keys at all levels of JSON structure
- **Fix Applied**: Replaced grep/sed parsing with Python JSON parsing for robust extraction

## Technical Fixes Implemented

### 1. Updated check-mcp-health.sh JSON Parsing
```bash
# OLD (broken) - extracted all JSON keys
server_names=$(grep -o '"[^"]*":' "$SCRIPT_DIR/mcp.json" | grep -v "mcpServers" | sed 's/[": ]//g' | sort)

# NEW (fixed) - properly extracts only server names
server_names=$(python3 -c "
import json
with open('$SCRIPT_DIR/mcp.json', 'r') as f:
    data = json.load(f)
    servers = data.get('mcpServers', {})
    for server in sorted(servers.keys()):
        print(server)
" 2>/dev/null || echo "git github brave-search playwright")
```

### 2. Setup Script Execution
- **Git MCP**: `./setup-git-mcp.sh` - Creates Python venv, installs dependencies
- **GitHub MCP**: `./setup-github-mcp.sh` - Compiles Go binary from source
- **Brave Search MCP**: `./setup-brave-search-mcp.sh` - Updates secrets template

## Current Status After Fixes

| Server | Status | Dependencies Met | Auth Required |
|--------|--------|------------------|---------------|
| Git | ✅ Ready | Python venv created | None |
| GitHub | ⚠️ Partial | Binary compiled | GitHub CLI auth needed |
| Brave Search | ⚠️ Partial | Setup complete | API key needed |
| Playwright | ✅ Ready | NPM available | None |

## Environment Context

This issue occurred in a **GitHub Actions environment** which starts as a clean slate without the full dotfiles setup. The MCP infrastructure was well-designed with:

- ✅ Comprehensive error logging framework
- ✅ Individual setup scripts for each server  
- ✅ Health checking and diagnostic tools
- ✅ Detailed documentation and troubleshooting procedures

The primary issue was simply that **setup scripts hadn't been run** in this environment, explaining why only Playwright (which requires no local setup) was working.

## Recommendations for Production

1. **Include MCP setup in CI/CD**: Run setup scripts during environment initialization
2. **Add pre-commit hooks**: Verify MCP health before commits
3. **Environment detection**: Automatically run setup for missing dependencies
4. **Credential management**: Implement secure handling for API keys and auth tokens

## Diagnostic Tools Available

The repository includes comprehensive diagnostic capabilities:
- `check-mcp-health.sh` - Server health verification (now fixed)
- `check-mcp-logs` - Error log analysis  
- `mcp/utils/mcp-logging.sh` - Logging framework
- Protocol smoke tests in knowledge base procedures

## Related Documentation

- [MCP Error Reporting Procedure](../knowledge/procedures/mcp-error-reporting.md)
- [MCP Protocol Smoke Test](../knowledge/procedures/mcp-protocol-smoke-test.md)
- [MCP Tool Logging](../knowledge/procedures/mcp-tool-logging.md)