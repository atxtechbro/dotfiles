#!/bin/bash
# Branch preparation script for Claude Code automation
# Ensures unique branch names and cleans up existing branches that might conflict

set -e

# Get issue number from environment or args
ISSUE_NUMBER="${1:-${ISSUE_NUMBER:-unknown}}"
RUN_ID="${GITHUB_RUN_ID:-${2:-unknown}}"

echo "Preparing branch environment for issue #$ISSUE_NUMBER (run: $RUN_ID)"

# Configure git with context that might influence Claude's branch naming
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

# Set a custom git config that Claude might pick up
git config --global claude.issue "$ISSUE_NUMBER"
git config --global claude.run "$RUN_ID"

# Function to clean up a branch if it exists
cleanup_branch() {
    local branch_name="$1"
    echo "Checking for existing branch: $branch_name"
    
    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Local branch $branch_name exists, deleting..."
        git branch -D "$branch_name" || true
    fi
    
    # Check if branch exists on remote
    if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
        echo "Remote branch $branch_name exists, deleting..."
        git push origin --delete "$branch_name" || true
    fi
}

# List of potential branch names Claude might use
# We'll clean these up to ensure no conflicts
POTENTIAL_BRANCHES=(
    "atx/dotbot-base-changes"
    "atx/issue-$ISSUE_NUMBER"
    "claude/issue-$ISSUE_NUMBER"
    "fix/issue-$ISSUE_NUMBER"
    "feature/issue-$ISSUE_NUMBER"
)

# Clean up any existing branches that might conflict
for branch in "${POTENTIAL_BRANCHES[@]}"; do
    cleanup_branch "$branch"
done

# Also check for any PR-specific branches from previous runs
echo "Checking for stale PR branches..."
git fetch origin --prune

# Set environment variables that might influence Claude's behavior
# These will be available to the Claude Code action
echo "Setting branch hint environment variables..."
export CLAUDE_BRANCH_PREFIX="issue-$ISSUE_NUMBER"
export CLAUDE_BRANCH_SUFFIX="$RUN_ID"
export GIT_BRANCH_PREFIX="issue-$ISSUE_NUMBER"

# Create a marker file with branch suggestions
# Claude might read this when deciding on branch names
cat > /tmp/branch-context.txt <<EOF
Issue: #$ISSUE_NUMBER
Run ID: $RUN_ID
Choose branch type based on issue:
- Bug fix: fix/issue-$ISSUE_NUMBER-$RUN_ID
- New feature: feature/issue-$ISSUE_NUMBER-$RUN_ID  
- Refactoring: refactor/issue-$ISSUE_NUMBER-$RUN_ID
- Documentation: docs/issue-$ISSUE_NUMBER-$RUN_ID
- Maintenance: chore/issue-$ISSUE_NUMBER-$RUN_ID
EOF

echo "Branch preparation complete"
echo "Suggested branch patterns (choose based on issue type):"
echo "  - fix/issue-$ISSUE_NUMBER-$RUN_ID"
echo "  - feature/issue-$ISSUE_NUMBER-$RUN_ID"
echo "  - refactor/issue-$ISSUE_NUMBER-$RUN_ID"
echo "  - docs/issue-$ISSUE_NUMBER-$RUN_ID"
echo "  - chore/issue-$ISSUE_NUMBER-$RUN_ID"