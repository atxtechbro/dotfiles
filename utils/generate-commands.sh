#!/bin/bash
# Generate AI provider commands using Python prompt orchestrator
# This vendor-agnostic script processes command templates for any AI provider
# Principle: systems-stewardship
#
# [TEMPLATE-GENERATION]
# This script DOES generate slash commands from templates.
# Templates are stored in .claude/command-templates/ and processed by prompt_orchestrator.py
# to create provider-specific commands with injected variables and knowledge base content.
# This allows slash commands to be dynamic and context-aware.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_ORCHESTRATOR="$SCRIPT_DIR/prompt_orchestrator.py"

# Configuration file for provider directories (if exists)
PROVIDER_CONFIG="$DOTFILES_DIR/.config/provider_dirs.conf"

# Default provider configurations (bash 3.2 compatible)
# Format: "provider:template_dir|output_dir"
DEFAULT_PROVIDERS=(
    "claude:$DOTFILES_DIR/.claude/command-templates|$HOME/.claude/commands"
    "amazonq:$DOTFILES_DIR/.claude/command-templates|$HOME/.amazonq/commands"
    "cursor:$DOTFILES_DIR/.claude/command-templates|$HOME/.cursor/commands"
)

# Function to get provider config
get_provider_config() {
    local provider="$1"
    for config in "${PROVIDER_CONFIGS[@]}"; do
        if [[ "$config" == "$provider:"* ]]; then
            echo "${config#*:}"
            return 0
        fi
    done
    return 1
}

# Load provider directories from config file if it exists
PROVIDER_CONFIGS=()
if [[ -f "$PROVIDER_CONFIG" ]]; then
    echo "Loading provider configuration from $PROVIDER_CONFIG..."
    while IFS='=' read -r provider paths; do
        # Skip comments and empty lines
        [[ "$provider" =~ ^#.*$ || -z "$provider" ]] && continue
        PROVIDER_CONFIGS+=("$provider:$paths")
    done < "$PROVIDER_CONFIG"
else
    # Use default configuration
    echo "No provider configuration found, using defaults..."
    PROVIDER_CONFIGS=("${DEFAULT_PROVIDERS[@]}")
fi

# Check if prompt orchestrator exists
if [[ ! -x "$PROMPT_ORCHESTRATOR" ]]; then
    echo "Error: prompt_orchestrator.py not found or not executable at: $PROMPT_ORCHESTRATOR"
    exit 1
fi

# Track if any templates were processed
TEMPLATES_PROCESSED=0

# Run cleanup before generating new commands
echo "Running cleanup to remove orphaned commands..."
if [[ -x "$SCRIPT_DIR/sync-claude-commands.sh" ]]; then
    "$SCRIPT_DIR/sync-claude-commands.sh" --clean
else
    echo "Warning: sync-claude-commands.sh not found or not executable"
fi
echo

# Process templates for each provider
for config in "${PROVIDER_CONFIGS[@]}"; do
    provider="${config%%:*}"
    paths="${config#*:}"
    IFS='|' read -r template_dir output_dir <<< "$paths"
    
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
            
            # Check if the output file has frontmatter
            has_frontmatter=false
            if head -n 1 "$output" | grep -q '^---$'; then
                has_frontmatter=true
            fi
            
            # Add provider-specific logging
            if [ "$has_frontmatter" = true ]; then
                # File has frontmatter, preserve it and inject logging after
                # Extract frontmatter
                awk '/^---$/{p++} p==1' "$output" > "$output.frontmatter"
                echo "---" >> "$output.frontmatter"
                
                # Extract content after frontmatter
                awk '/^---$/{p++} p==2{print; exit}' "$output" | tail -n +2 > "$output.content"
                awk '/^---$/{p++} p>1' "$output" | tail -n +2 >> "$output.content"
                
                # Rebuild file with frontmatter, then logging, then content
                cp "$output.frontmatter" "$output.tmp"
                
                case "$provider" in
                    claude)
                        # Claude-specific logging
                        cat >> "$output.tmp" << EOF
!echo "\$(date '+%Y-%m-%d %H:%M:%S') $command_name \$ARGUMENTS" >> ~/claude-slash-commands.log

EOF
                        # Add command-specific validation
                        case "$command_name" in
                            close-issue)
                                # Inject shell validation for close-issue
                                cat >> "$output.tmp" << 'EOF'
if [ -z "$ISSUE_NUMBER" ]; then
    echo "Error: The /close-issue command requires a GitHub issue number. Usage: /close-issue <number>"
    exit 1
fi

EOF
                                ;;
                        esac
                        ;;
                    amazonq)
                        # Amazon Q might have different logging needs
                        cat >> "$output.tmp" << EOF
# Amazon Q command: $command_name
# Generated: $(date '+%Y-%m-%d %H:%M:%S')

EOF
                        ;;
                    *)
                        # Generic provider logging
                        cat >> "$output.tmp" << EOF
# Command: $command_name
# Provider: $provider
# Generated: $(date '+%Y-%m-%d %H:%M:%S')

EOF
                        ;;
                esac
                
                # Append the content after frontmatter
                cat "$output.content" >> "$output.tmp"
                
                # Clean up temporary files
                rm -f "$output.frontmatter" "$output.content"
            else
                # No frontmatter, add logging at the beginning as before
                case "$provider" in
                    claude)
                        # Claude-specific logging
                        cat > "$output.tmp" << EOF
!echo "\$(date '+%Y-%m-%d %H:%M:%S') $command_name \$ARGUMENTS" >> ~/claude-slash-commands.log

EOF
                        # Add command-specific validation
                        case "$command_name" in
                            close-issue)
                                # Inject shell validation for close-issue
                                cat >> "$output.tmp" << 'EOF'
if [ -z "$ISSUE_NUMBER" ]; then
    echo "Error: The /close-issue command requires a GitHub issue number. Usage: /close-issue <number>"
    exit 1
fi

EOF
                                ;;
                        esac
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
            fi
            
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