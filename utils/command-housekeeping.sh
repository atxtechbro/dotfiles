#!/bin/bash
# Reusable housekeeping functions for command generation
# Source this file in generate-commands.sh to use these functions
# Principle: generation-time-validation

# Check if GitHub CLI is authenticated
check_github_auth() {
    if ! gh auth status &>/dev/null; then
        cat << 'EOF'
if ! gh auth status &>/dev/null; then
    echo "Error: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

EOF
    fi
}

# Validate and pre-fetch issue data
inject_issue_validation() {
    cat << 'EOF'
# Validate issue exists and pre-fetch data
if [ -n "$ISSUE_NUMBER" ]; then
    echo "Validating issue #$ISSUE_NUMBER..."
    
    # Check if issue exists
    if ! issue_json=$(gh issue view "$ISSUE_NUMBER" --json state,title,labels,body 2>/dev/null); then
        echo "Error: Issue #$ISSUE_NUMBER not found"
        exit 1
    fi
    
    # Extract issue data
    export ISSUE_STATE=$(echo "$issue_json" | jq -r .state)
    export ISSUE_TITLE=$(echo "$issue_json" | jq -r .title)
    export ISSUE_LABELS=$(echo "$issue_json" | jq -r '.labels[].name' | tr '\n' ',' | sed 's/,$//')
    
    # Warn if already closed
    if [ "$ISSUE_STATE" = "CLOSED" ]; then
        echo "Warning: Issue #$ISSUE_NUMBER is already closed"
        echo "State: $ISSUE_STATE"
    fi
    
    echo "Issue validated: $ISSUE_TITLE"
fi

EOF
}

# Check git working directory state
inject_git_state_validation() {
    cat << 'EOF'
# Check git state
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Warning: Uncommitted changes detected"
    echo "Auto-stashing changes..."
    git stash push -m "Auto-stash for command execution at $(date)"
    
    # Register cleanup to restore state
    trap 'echo "Restoring stashed changes..."; git stash pop' EXIT
fi

# Check current branch
current_branch=$(git branch --show-current)
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    echo "Error: Cannot execute this command on $current_branch branch"
    echo "Please switch to a feature branch first"
    exit 1
fi

EOF
}

# Pre-flight check for PR commands
inject_pr_validation() {
    cat << 'EOF'
# Validate PR exists and pre-fetch data
if [ -n "$PR_NUMBER" ]; then
    echo "Validating PR #$PR_NUMBER..."
    
    if ! pr_json=$(gh pr view "$PR_NUMBER" --json state,title,baseRefName,headRefName 2>/dev/null); then
        echo "Error: PR #$PR_NUMBER not found"
        exit 1
    fi
    
    export PR_STATE=$(echo "$pr_json" | jq -r .state)
    export PR_TITLE=$(echo "$pr_json" | jq -r .title)
    export PR_BASE_BRANCH=$(echo "$pr_json" | jq -r .baseRefName)
    export PR_HEAD_BRANCH=$(echo "$pr_json" | jq -r .headRefName)
    
    if [ "$PR_STATE" = "MERGED" ] || [ "$PR_STATE" = "CLOSED" ]; then
        echo "Warning: PR #$PR_NUMBER is $PR_STATE"
    fi
fi

EOF
}

# Set up worktree path for isolated development
inject_worktree_setup() {
    cat << 'EOF'
# Set up worktree path for isolation
if [ -n "$ISSUE_NUMBER" ]; then
    branch_name="feature/${command_name}-${ISSUE_NUMBER}"
    export WORKTREE_PATH="$HOME/ppv/pillars/dotfiles/worktrees/$branch_name"
    
    if [ -d "$WORKTREE_PATH" ]; then
        echo "Info: Will use existing worktree at $WORKTREE_PATH"
    else
        echo "Info: Will create new worktree at $WORKTREE_PATH"
    fi
fi

EOF
}

# Check for required CLI tools
inject_tool_requirements() {
    local tools="$1"
    cat << EOF
# Check required tools
required_tools="$tools"
for tool in \$required_tools; do
    if ! command -v "\$tool" &> /dev/null; then
        echo "Error: Required tool '\$tool' not found"
        case "\$tool" in
            gh) echo "Install with: https://cli.github.com/" ;;
            jq) echo "Install with: sudo apt install jq" ;;
            rg) echo "Install with: sudo apt install ripgrep" ;;
            *) echo "Please install \$tool" ;;
        esac
        exit 1
    fi
done

EOF
}

# Fetch recent context for pattern matching
inject_recent_pr_context() {
    cat << 'EOF'
# Fetch recent merged PRs for pattern reference
echo "Fetching recent PR patterns..."
export RECENT_PRS=$(gh pr list --state merged --limit 5 --json number,title,files \
    --jq '.[] | "PR #\(.number): \(.title)"' 2>/dev/null || echo "")

if [ -n "$RECENT_PRS" ]; then
    echo "Recent merged PRs for reference:"
    echo "$RECENT_PRS" | sed 's/^/  /'
fi

EOF
}

# Main injection function called from generate-commands.sh
inject_housekeeping() {
    local command_name="$1"
    
    case "$command_name" in
        close-issue|update-issue|comment-issue)
            inject_issue_validation
            inject_git_state_validation
            inject_worktree_setup
            inject_tool_requirements "gh jq git"
            ;;
            
        create-pr|review-pr|merge-pr)
            inject_pr_validation
            inject_git_state_validation
            inject_tool_requirements "gh jq git"
            ;;
            
        *)
            # Default minimal validation
            inject_tool_requirements "git"
            ;;
    esac
}