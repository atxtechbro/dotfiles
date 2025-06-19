#!/bin/bash

# MCP Prompt Storage PoC
# Demonstrates how to use stored prompts with Amazon Q CLI and git MCP server

set -e

PROMPTS_DIR="$(dirname "$0")/prompts"

# Function to load and process a prompt template
load_prompt() {
    local prompt_file="$1"
    local output_file="/tmp/processed_prompt.md"
    
    if [[ ! -f "$prompt_file" ]]; then
        echo "Error: Prompt file not found: $prompt_file"
        return 1
    fi
    
    echo "Loading prompt: $prompt_file"
    
    # Extract frontmatter and content
    local content=$(sed '1,/^---$/d; /^---$/,$d' "$prompt_file")
    
    # For this PoC, we'll do simple variable substitution
    # In a real implementation, this would be handled by the MCP server
    
    # Get git context
    local git_status=$(git status --porcelain 2>/dev/null || echo "Not a git repository")
    local git_diff_staged=$(git diff --cached 2>/dev/null || echo "No staged changes")
    local git_log=$(git log --oneline -5 2>/dev/null || echo "No git history")
    local git_diff=$(git diff HEAD~5..HEAD 2>/dev/null || echo "No recent changes")
    
    # Replace template variables
    content="${content//\{\{git_status\}\}/$git_status}"
    content="${content//\{\{git_diff_staged\}\}/$git_diff_staged}"
    content="${content//\{\{git_log\}\}/$git_log}"
    content="${content//\{\{git_diff\}\}/$git_diff}"
    
    # Write processed prompt
    echo "$content" > "$output_file"
    echo "Processed prompt saved to: $output_file"
    
    return 0
}

# Function to use prompt with Amazon Q CLI
use_prompt_with_q() {
    local prompt_name="$1"
    local prompt_file="$PROMPTS_DIR/$prompt_name.md"
    
    # Find the prompt file
    if [[ ! -f "$prompt_file" ]]; then
        # Try to find it in subdirectories
        prompt_file=$(find "$PROMPTS_DIR" -name "$prompt_name.md" -type f | head -1)
        
        if [[ -z "$prompt_file" ]]; then
            echo "Error: Prompt '$prompt_name' not found"
            echo "Available prompts:"
            find "$PROMPTS_DIR" -name "*.md" -not -name "README.md" | sed "s|$PROMPTS_DIR/||; s|\.md$||"
            return 1
        fi
    fi
    
    echo "Using prompt: $prompt_name"
    
    # Load and process the prompt
    if load_prompt "$prompt_file"; then
        echo ""
        echo "=== Processed Prompt ==="
        cat /tmp/processed_prompt.md
        echo ""
        echo "=== Amazon Q CLI Integration ==="
        echo "To use this with Amazon Q CLI:"
        echo "1. Copy the processed prompt above"
        echo "2. Run: q chat --trust-tools=git___git_status,git___git_diff_staged"
        echo "3. Paste the prompt in the chat"
        echo ""
        echo "Or for automated usage:"
        echo "q chat --trust-tools=git___git_status,git___git_diff_staged < /tmp/processed_prompt.md"
    fi
}

# Function to list available prompts
list_prompts() {
    echo "Available prompts:"
    find "$PROMPTS_DIR" -name "*.md" -not -name "README.md" | while read -r file; do
        local name=$(basename "$file" .md)
        local path=$(dirname "$file" | sed "s|$PROMPTS_DIR/||")
        local description=$(grep "^description:" "$file" | cut -d: -f2- | sed 's/^ *//')
        
        if [[ "$path" != "." ]]; then
            name="$path/$name"
        fi
        
        printf "  %-20s %s\n" "$name" "$description"
    done
}

# Function to demonstrate the concept
demo() {
    echo "=== MCP Prompt Storage PoC Demo ==="
    echo ""
    
    echo "This PoC demonstrates how we could store reusable prompts"
    echo "in version control and use them with Amazon Q CLI via MCP."
    echo ""
    
    list_prompts
    echo ""
    
    echo "Example usage:"
    echo "  $0 use commit-message"
    echo "  $0 use git/pr-description"
    echo "  $0 use development/debug-session"
    echo ""
    
    echo "The vision is that these prompts would be:"
    echo "- Automatically loaded by an MCP server"
    echo "- Invokable with @prompt-name syntax in Q chat"
    echo "- Context-aware (auto-inject git status, file contents, etc.)"
    echo "- Shareable across team members"
    echo "- Version-controlled for iteration and improvement"
}

# Main script logic
case "${1:-demo}" in
    "list")
        list_prompts
        ;;
    "use")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 use <prompt-name>"
            echo ""
            list_prompts
            exit 1
        fi
        use_prompt_with_q "$2"
        ;;
    "demo"|*)
        demo
        ;;
esac
