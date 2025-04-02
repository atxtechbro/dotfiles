#!/bin/bash

# Log the start of the script
echo "Starting script to get latest failed workflow logs..."

# Check if a repository is provided as an argument
if [[ $# -eq 2 ]]; then
  repo_owner=$1
  repo_name=$2
  echo "Repository owner: $repo_owner"
  echo "Repository name: $repo_name"
elif [[ $# -eq 0 ]]; then
  # Check if we're in a git repository first
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get the repository owner and name from the origin remote
    remote_url=$(git remote get-url origin)
    repo_owner=$(echo "$remote_url" | sed -E 's#.*github.com[:/]([^/]+)/.*#\1#')
    repo_name=$(echo "$remote_url" | sed -E 's#.*github.com[:/].*/([^/]+).*#\1#' | sed 's/\.git$//') # Remove .git
    # Log the repository information
    echo "Repository owner: $repo_owner"
    echo "Repository name: $repo_name"
  else
    echo "Error: Not in a git repository. Please provide owner and repo name."
    echo "Usage: $0 [owner] [repo]"
    exit 1
  fi
else
  echo "Usage: $0 [owner] [repo]"
  echo "Or run in a git repository to use the origin remote."
  exit 1
fi

# Check if gh and jq are installed
if ! command -v gh &> /dev/null; then
  echo "Error: gh command not found. Please install the GitHub CLI."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq command not found. Please install jq."
  exit 1
fi

# Get the latest workflow run ID (using jq) and redirect stderr to stdout
run_id=$(gh run list -L 1 --json databaseId -R "$repo_owner/$repo_name" 2>/dev/null | jq -r '.[0].databaseId')

# Check if the gh command failed or if no runs were found
if [[ -z "$run_id" ]]; then
  echo "No workflow runs found or failed to get run list."
  exit 1
fi

# Log the run ID
echo "Latest workflow run ID: $run_id"

# Get the run conclusion (e.g., "success", "failure") and redirect stderr to stdout
conclusion=$(gh run view $run_id --json conclusion -R "$repo_owner/$repo_name" 2>/dev/null | jq -r '.conclusion')

# Check if the gh command failed
if [[ -z "$conclusion" ]]; then
  echo "Error: Failed to get workflow run details."
  exit 1
fi

# Log the run conclusion
echo "Workflow run conclusion: $conclusion"

# Check if the run failed
if [[ "$conclusion" == "failure" ]]; then
  # Log the failure and view the failed logs
  echo "Workflow run failed. Viewing failed logs..."
  gh run view $run_id --log-failed -R "$repo_owner/$repo_name"
else
  echo "The latest workflow run was successful."
fi

# Log the end of the script
echo "Script finished."