# Generation-Time Validations Catalog

A comprehensive list of validations that can and should be moved to generation-time in `generate-commands.sh`.

## Parameter Validations

### Required Parameters
```bash
# Pattern for any required parameter
if [ -z "$PARAM_NAME" ]; then
    echo "Error: PARAM_NAME is required. Usage: /command <param>"
    exit 1
fi
```

Currently applicable to:
- `close-issue`: ISSUE_NUMBER
- Future: Any command with required parameters

### Parameter Format Validations
```bash
# Numeric parameters
if ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: ISSUE_NUMBER must be a number"
    exit 1
fi

# URL format
if ! [[ "$URL" =~ ^https?:// ]]; then
    echo "Error: URL must start with http:// or https://"
    exit 1
fi
```

## Git State Validations

### Clean Working Directory
```bash
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: Uncommitted changes detected. Commit or stash first."
    exit 1
fi
```

### On Correct Branch
```bash
if [[ "$(git branch --show-current)" == "main" ]]; then
    echo "Error: Cannot run this command on main branch"
    exit 1
fi
```

### Up to Date with Origin
```bash
git fetch origin main
if ! git diff --quiet HEAD..origin/main; then
    echo "Warning: Local main is behind origin/main"
    echo "Consider: git pull origin main"
fi
```

## Environment Validations

### Required Tools
```bash
# Check for required CLI tools
for tool in gh jq; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool '$tool' not found"
        echo "Install with: [installation command]"
        exit 1
    fi
done
```

### Authentication Status
```bash
# GitHub CLI auth check
if ! gh auth status &>/dev/null; then
    echo "Error: Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi
```

### Required Environment Variables
```bash
# Check for required secrets
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN not set"
    echo "Add to ~/.bash_secrets"
    exit 1
fi
```

## Pre-fetching Data

### Issue Validation and Context
```bash
# For issue-related commands, pre-fetch and validate
if [ -n "$ISSUE_NUMBER" ]; then
    # Check if issue exists and is open
    issue_state=$(gh issue view "$ISSUE_NUMBER" --json state -q .state 2>/dev/null)
    if [ -z "$issue_state" ]; then
        echo "Error: Issue #$ISSUE_NUMBER not found"
        exit 1
    fi
    if [ "$issue_state" = "CLOSED" ]; then
        echo "Warning: Issue #$ISSUE_NUMBER is already closed"
    fi
    
    # Pre-fetch issue data for context
    export ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title -q .title)
    export ISSUE_LABELS=$(gh issue view "$ISSUE_NUMBER" --json labels -q '.labels[].name' | tr '\n' ',')
fi
```

### PR Validation
```bash
# For PR-related commands
if [ -n "$PR_NUMBER" ]; then
    pr_state=$(gh pr view "$PR_NUMBER" --json state -q .state 2>/dev/null)
    if [ -z "$pr_state" ]; then
        echo "Error: PR #$PR_NUMBER not found"
        exit 1
    fi
fi
```

## Workspace Preparation

### Auto-stashing
```bash
# Automatically stash changes if needed
if ! git diff --quiet; then
    echo "Stashing uncommitted changes..."
    git stash push -m "Auto-stash before $command_name"
    trap 'git stash pop' EXIT
fi
```

### Worktree Setup
```bash
# For commands that need isolation
if [[ "$command_name" == "close-issue" ]]; then
    # Set up worktree path
    export WORKTREE_PATH="$HOME/ppv/pillars/dotfiles/worktrees/feature/$command_name-$ISSUE_NUMBER"
    
    # Check if worktree already exists
    if [ -d "$WORKTREE_PATH" ]; then
        echo "Using existing worktree: $WORKTREE_PATH"
    else
        echo "Will create worktree at: $WORKTREE_PATH"
    fi
fi
```

## State Cleanup

### Post-command Cleanup
```bash
# Register cleanup functions
trap 'cleanup_function' EXIT

cleanup_function() {
    # Remove temporary files
    rm -f /tmp/command-$$-*
    
    # Reset any changed state
    cd "$ORIGINAL_DIR"
}
```

## Implementation Pattern

In `generate-commands.sh`, these would be injected based on command metadata:

```bash
case "$command_name" in
    close-issue|update-issue|review-issue)
        # Inject issue validation
        inject_issue_validation
        # Inject git state checks
        inject_git_state_validation
        # Inject worktree setup
        inject_worktree_prep
        ;;
    
    create-pr|merge-pr)
        # Inject PR validation
        inject_pr_validation
        # Inject branch checks
        inject_branch_validation
        ;;
esac
```

## Benefits

1. **Zero token cost**: All validation happens before AI sees anything
2. **Fail fast**: Problems caught immediately
3. **Context enrichment**: Pre-fetched data available to templates
4. **Automatic cleanup**: State management handled systematically
5. **Consistent experience**: Same validations for all AI providers

## Anti-patterns Prevented

- Asking AI to check if issue exists
- Token waste on "first check git status"
- Manual stashing instructions in templates
- Repeated auth checks in every command
- Inconsistent error handling