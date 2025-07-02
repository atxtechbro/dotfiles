#!/bin/bash
# Generate AI provider commands using Python prompt orchestrator
# This vendor-agnostic script processes command templates for any AI provider
# Principle: systems-stewardship

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_ORCHESTRATOR="$SCRIPT_DIR/prompt_orchestrator.py"

# Configuration file for provider directories (if exists)
PROVIDER_CONFIG="$DOTFILES_DIR/.config/provider_dirs.conf"

# Default provider directories if no config file exists
declare -A DEFAULT_PROVIDER_DIRS=(
    ["claude"]="$DOTFILES_DIR/.claude/command-templates|$HOME/.claude/commands"
    ["amazonq"]="$DOTFILES_DIR/.amazonq/command-templates|$HOME/.amazonq/commands"
    ["cursor"]="$DOTFILES_DIR/.cursor/command-templates|$HOME/.cursor/commands"
)

# Load provider directories from config file if it exists
declare -A PROVIDER_DIRS
if [[ -f "$PROVIDER_CONFIG" ]]; then
    echo "Loading provider configuration from $PROVIDER_CONFIG..."
    while IFS='=' read -r provider paths; do
        # Skip comments and empty lines
        [[ "$provider" =~ ^#.*$ || -z "$provider" ]] && continue
        PROVIDER_DIRS["$provider"]="$paths"
    done < "$PROVIDER_CONFIG"
else
    # Use default configuration
    echo "No provider configuration found, using defaults..."
    for provider in "${!DEFAULT_PROVIDER_DIRS[@]}"; do
        PROVIDER_DIRS["$provider"]="${DEFAULT_PROVIDER_DIRS[$provider]}"
    done
fi

# Check if prompt orchestrator exists
if [[ ! -x "$PROMPT_ORCHESTRATOR" ]]; then
    echo "Error: prompt_orchestrator.py not found or not executable at: $PROMPT_ORCHESTRATOR"
    exit 1
fi

# Track if any templates were processed
TEMPLATES_PROCESSED=0

# Process templates for each provider
for provider in "${!PROVIDER_DIRS[@]}"; do
    IFS='|' read -r template_dir output_dir <<< "${PROVIDER_DIRS[$provider]}"
    
    # Skip if template directory doesn't exist
    if [[ ! -d "$template_dir" ]]; then
        echo "Skipping $provider: template directory not found at $template_dir"
        continue
    fi
    
    # Check if templates directory is empty
    template_count=$(find "$template_dir" -name "*.md" -type f 2>/dev/null | wc -l)
    if [[ $template_count -eq 0 ]]; then
        echo "Warning: No template files found in $template_dir for $provider"
        continue
    fi
    
    echo "Processing $provider commands ($template_count templates found)..."
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Process all template files
    for template in "$template_dir"/*.md; do
        if [[ -f "$template" ]]; then
            filename=$(basename "$template")
            output="$output_dir/$filename"
            command_name="${filename%.md}"
            
            echo "  Processing: $filename"
            
            # First, process the template
            "$PROMPT_ORCHESTRATOR" "$template" \
                -o "$output" \
                -v ISSUE_NUMBER='$ISSUE_NUMBER' \
                -k "$DOTFILES_DIR/knowledge"
            
            # Add provider-specific logging
            case "$provider" in
                claude)
                    # Claude-specific logging
                    cat > "$output.tmp" << EOF
!echo "\$(date '+%Y-%m-%d %H:%M:%S') $command_name \$ARGUMENTS" >> ~/claude-slash-commands.log

EOF
                    ;;
                amazonq)
                    # Amazon Q might have different logging needs
                    cat > "$output.tmp" << EOF
# Amazon Q command: $command_name
# Generated: $(date '+%Y-%m-%d %H:%M:%S')

EOF
                    ;;
                *)
                    # Generic provider logging
                    cat > "$output.tmp" << EOF
# Command: $command_name
# Provider: $provider
# Generated: $(date '+%Y-%m-%d %H:%M:%S')

EOF
                    ;;
            esac
            
            # Append the original content
            cat "$output" >> "$output.tmp"
            
            # Replace original with logged version
            mv "$output.tmp" "$output"
            
            TEMPLATES_PROCESSED=$((TEMPLATES_PROCESSED + 1))
        fi
    done
    
    echo "  Generated commands available at: $output_dir"
done

# Final status
if [[ $TEMPLATES_PROCESSED -eq 0 ]]; then
    echo "Error: No templates were processed. Please check your template directories."
    exit 1
else
    echo "Successfully processed $TEMPLATES_PROCESSED command template(s)!"
fi