#!/bin/bash
# Prefetch GitHub issue data for commands to eliminate API calls from intelligence layer
# Principle: subtraction-creates-value
#
# This script is sourced by generate-commands.sh to prefetch issue/PR data
# and export it as environment variables for use in command templates

set -euo pipefail

# Function to prefetch GitHub issue data
# Usage: prefetch_issue_data <issue_number>
# Exports: ISSUE_STATE, ISSUE_TITLE, ISSUE_BODY, ISSUE_LABELS, ISSUE_COMMENTS
prefetch_issue_data() {
    local issue_number="$1"
    
    if [ -z "$issue_number" ]; then
        echo "Error: Issue number required for prefetching"
        return 1
    fi
    
    echo "Prefetching GitHub issue #$issue_number data..."
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        echo "Warning: GitHub CLI (gh) not found - skipping prefetch"
        echo "Install from: https://cli.github.com/"
        return 0  # Non-fatal to allow offline development
    fi
    
    # Check authentication
    if ! gh auth status &>/dev/null; then
        echo "Warning: Not authenticated with GitHub - skipping prefetch"
        echo "Run: gh auth login"
        return 0  # Non-fatal
    fi
    
    # Fetch issue data
    if ! issue_json=$(gh issue view "$issue_number" --json state,title,body,labels,assignees 2>/dev/null); then
        echo "Error: Issue #$issue_number not found or not accessible"
        return 1
    fi
    
    # Export issue metadata
    export ISSUE_STATE=$(echo "$issue_json" | jq -r .state)
    export ISSUE_TITLE=$(echo "$issue_json" | jq -r .title)
    export ISSUE_BODY=$(echo "$issue_json" | jq -r .body // "")
    export ISSUE_LABELS=$(echo "$issue_json" | jq -r '.labels[].name' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
    export ISSUE_ASSIGNEES=$(echo "$issue_json" | jq -r '.assignees[].login' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
    
    # Fetch comments separately
    if comments_json=$(gh issue comment list "$issue_number" --json author,body,createdAt 2>/dev/null); then
        # Export as JSON string for agent parsing
        export ISSUE_COMMENTS="$comments_json"
        local comment_count=$(echo "$comments_json" | jq '. | length')
        echo "  ✓ Fetched issue data and $comment_count comment(s)"
    else
        export ISSUE_COMMENTS="[]"
        echo "  ✓ Fetched issue data (no comments)"
    fi
    
    # Display summary
    echo "  State: $ISSUE_STATE"
    echo "  Title: $ISSUE_TITLE"
    [ -n "$ISSUE_LABELS" ] && echo "  Labels: $ISSUE_LABELS"
    
    # Warn if already closed
    if [ "$ISSUE_STATE" = "CLOSED" ]; then
        echo "  ⚠️  Warning: Issue #$issue_number is already closed"
    fi
    
    return 0
}

# Function to prefetch GitHub PR data
# Usage: prefetch_pr_data <pr_number>
# Exports: PR_STATE, PR_TITLE, PR_BODY, PR_LABELS, PR_BASE, PR_HEAD, PR_COMMENTS
prefetch_pr_data() {
    local pr_number="$1"
    
    if [ -z "$pr_number" ]; then
        echo "Error: PR number required for prefetching"
        return 1
    fi
    
    echo "Prefetching GitHub PR #$pr_number data..."
    
    # Check prerequisites (same as issue)
    if ! command -v gh &> /dev/null; then
        echo "Warning: GitHub CLI (gh) not found - skipping prefetch"
        return 0
    fi
    
    if ! gh auth status &>/dev/null; then
        echo "Warning: Not authenticated with GitHub - skipping prefetch"
        return 0
    fi
    
    # Fetch PR data
    if ! pr_json=$(gh pr view "$pr_number" --json state,title,body,labels,baseRefName,headRefName,mergeable,isDraft 2>/dev/null); then
        echo "Error: PR #$pr_number not found or not accessible"
        return 1
    fi
    
    # Export PR metadata
    export PR_STATE=$(echo "$pr_json" | jq -r .state)
    export PR_TITLE=$(echo "$pr_json" | jq -r .title)
    export PR_BODY=$(echo "$pr_json" | jq -r .body // "")
    export PR_LABELS=$(echo "$pr_json" | jq -r '.labels[].name' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
    export PR_BASE=$(echo "$pr_json" | jq -r .baseRefName)
    export PR_HEAD=$(echo "$pr_json" | jq -r .headRefName)
    export PR_MERGEABLE=$(echo "$pr_json" | jq -r .mergeable)
    export PR_IS_DRAFT=$(echo "$pr_json" | jq -r .isDraft)
    
    # Fetch PR comments
    if comments_json=$(gh pr comment list "$pr_number" --json author,body,createdAt 2>/dev/null); then
        export PR_COMMENTS="$comments_json"
        local comment_count=$(echo "$comments_json" | jq '. | length')
        echo "  ✓ Fetched PR data and $comment_count comment(s)"
    else
        export PR_COMMENTS="[]"
        echo "  ✓ Fetched PR data (no comments)"
    fi
    
    # Display summary
    echo "  State: $PR_STATE"
    echo "  Title: $PR_TITLE"
    echo "  Branch: $PR_BASE <- $PR_HEAD"
    [ "$PR_IS_DRAFT" = "true" ] && echo "  Status: Draft"
    
    return 0
}

# Main prefetch orchestrator
# Usage: prefetch_github_data <type> <number>
# Where type is "issue" or "pr"
prefetch_github_data() {
    local type="$1"
    local number="$2"
    
    case "$type" in
        issue)
            prefetch_issue_data "$number"
            ;;
        pr|pull-request)
            prefetch_pr_data "$number"
            ;;
        *)
            echo "Error: Unknown prefetch type '$type'. Use 'issue' or 'pr'"
            return 1
            ;;
    esac
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f prefetch_issue_data
    export -f prefetch_pr_data
    export -f prefetch_github_data
fi