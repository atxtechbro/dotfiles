#!/bin/bash
# Parallel MCP server setup with caching
# Optimized version that runs server setups concurrently

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR"
REPO_ROOT="$(dirname "$MCP_DIR")"

source "$REPO_ROOT/utils/parallel-setup.sh"
source "$REPO_ROOT/utils/cache-utils.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Setting up all MCP servers in parallel...${NC}"
echo "Working directory: $REPO_ROOT"

# Check if we're in a worktree
IS_WORKTREE=false
if git rev-parse --git-common-dir >/dev/null 2>&1; then
    GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
    GIT_DIR=$(git rev-parse --git-dir)
    if [ "$GIT_COMMON_DIR" != "$GIT_DIR" ]; then
        echo -e "${YELLOW}Detected git worktree - ensuring local setup${NC}"
        IS_WORKTREE=true
    fi
fi

# Define MCP server jobs
declare -a MCP_SETUP_JOBS=(
    "github-mcp:cd '$MCP_DIR' && ./setup-github-mcp.sh"
    "git-mcp:cd '$MCP_DIR' && ./setup-git-mcp.sh"
    "brave-search-mcp:cd '$MCP_DIR' && ./setup-brave-search-mcp.sh"
)

# Check cache for each server before running
echo -e "\n${BLUE}Checking MCP server cache...${NC}"
declare -a jobs_to_run=()

for job in "${MCP_SETUP_JOBS[@]}"; do
    job_name="${job%%:*}"
    
    if is_cached "mcp-server-$job_name" 7; then  # Cache for 7 days
        echo -e "${GREEN}✓ $job_name already configured (cached)${NC}"
    else
        jobs_to_run+=("$job")
    fi
done

if [[ ${#jobs_to_run[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ All MCP servers already configured${NC}"
    exit 0
fi

# Run uncached setups in parallel
echo -e "\n${BLUE}Running ${#jobs_to_run[@]} MCP server setups in parallel...${NC}"

for job in "${jobs_to_run[@]}"; do
    job_name="${job%%:*}"
    job_command="${job#*:}"
    
    # Wrap command to mark as cached on success
    wrapped_command="if $job_command; then echo 'Marking $job_name as cached'; source '$REPO_ROOT/utils/cache-utils.sh' && mark_cached 'mcp-server-$job_name'; fi"
    
    start_parallel_job "$job_name" bash -c "$wrapped_command"
done

# Wait for all jobs to complete
if wait_parallel_jobs; then
    echo -e "\n${GREEN}✓ All MCP servers configured successfully${NC}"
    
    # Generate MCP configuration
    if [[ -f "$MCP_DIR/generate-mcp-config.sh" ]]; then
        echo -e "\n${BLUE}Generating MCP configuration files...${NC}"
        "$MCP_DIR/generate-mcp-config.sh"
    fi
else
    echo -e "\n${RED}Some MCP server setups failed. Check the logs for details.${NC}"
    exit 1
fi