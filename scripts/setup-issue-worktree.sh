#!/usr/bin/env bash
# Helper script to avoid bash escaping issues in close-issue command
# Usage: setup-issue-worktree.sh <issue_number> <issue_title> <worktree_base> <use_worktree>

set -euo pipefail

# Validate required arguments
if [ $# -lt 3 ]; then
  echo "Error: Missing required arguments" >&2
  echo "Usage: setup-issue-worktree.sh <issue_number> <issue_title> <worktree_base> [use_worktree]" >&2
  exit 1
fi

ISSUE_NUMBER="$1"
ISSUE_TITLE="$2"
WORKTREE_BASE="$3"
USE_WORKTREE="${4:-true}"

# Validate issue number is numeric
if ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "Error: Issue number must be numeric, got: $ISSUE_NUMBER" >&2
  exit 1
fi

# Convert title to slug (avoiding escaping issues in markdown bash blocks)
ISSUE_SLUG=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | cut -c1-50)
if [ -z "$ISSUE_SLUG" ] || [ ${#ISSUE_SLUG} -lt 3 ]; then
  ISSUE_SLUG="issue-implementation"
fi

BRANCH_NAME="issue-${ISSUE_NUMBER}-${ISSUE_SLUG}"

if [ "$USE_WORKTREE" = "true" ]; then
  WORKTREE_PATH="$WORKTREE_BASE/issue-${ISSUE_NUMBER}"
  echo "Creating worktree at: $WORKTREE_PATH"
  git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
  echo "WORKTREE_PATH=$WORKTREE_PATH"
else
  echo "Working in main repo (no worktree)"
  git checkout -b "$BRANCH_NAME"
fi

echo "BRANCH_NAME=$BRANCH_NAME"
