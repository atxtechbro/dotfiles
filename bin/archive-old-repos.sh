#!/bin/bash

set -euo pipefail

USER=$(gh api user | jq -r .login 2>/dev/null)
echo "Fetching repositories for $USER..."

# Use --no-archived flag directly to avoid filtering in script
repos=$(gh repo list "$USER" --limit 100 --no-archived --json name,updatedAt \
  --jq '.[] | [.name, .updatedAt] | @tsv' | sort -k2)

repo_count=$(echo "$repos" | grep -c '^' || true)
if [[ "$repo_count" -eq 0 ]]; then
  echo "No unarchived repositories found."
  exit 0
fi

echo "Found $repo_count unarchived repositories (reviewing oldest first)."

# Convert repos to array for easier processing
mapfile -t repo_array < <(echo "$repos")

for repo_line in "${repo_array[@]}"; do
  IFS=$'\t' read -r name updated <<< "$repo_line"
  
  # Calculate days since last update
  if [[ "$OSTYPE" == "darwin"* ]]; then
    updated_date=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated" +%s)
  else
    updated_date=$(date -d "$updated" +%s)
  fi
  current_date=$(date +%s)
  days_ago=$(( (current_date - updated_date) / 86400 ))
  
  echo "Repo: $name ($days_ago days ago)"
  read -p "Archive? (y/N): " answer
  
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    gh repo archive "$USER/$name" --yes
  else
    echo -n "." # Just print a dot for skipped repos
  fi
done

echo "Done!"
