#!/bin/bash
# Prevent accidental AWS Bedrock charges by ensuring Claude Code uses Claude Pro

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Preventing AWS Bedrock charges...${NC}"

# 1. Remove any Bedrock-related environment variables
echo -e "${YELLOW}Checking for Bedrock environment variables...${NC}"
if env | grep -q "CLAUDE_CODE_USE_BEDROCK"; then
    echo -e "${RED}WARNING: CLAUDE_CODE_USE_BEDROCK is set. Unsetting it.${NC}"
    unset CLAUDE_CODE_USE_BEDROCK
fi

# 2. Check and remove credentials.json if it contains Bedrock config
CREDS_FILE="$HOME/.claude/.credentials.json"
if [ -f "$CREDS_FILE" ]; then
    if grep -q "bedrock\|aws" "$CREDS_FILE" 2>/dev/null; then
        echo -e "${RED}Bedrock configuration detected in credentials. Backing up and removing...${NC}"
        cp "$CREDS_FILE" "${CREDS_FILE}.bedrock-backup.$(date +%Y%m%d_%H%M%S)"
        rm -f "$CREDS_FILE"
        echo -e "${GREEN}Credentials removed. You'll need to login again with Claude Pro.${NC}"
    else
        echo -e "${GREEN}Credentials file exists and contains Claude Pro auth.${NC}"
    fi
fi

# 3. Add protection to shell profile
SHELL_RC=""
if [ -n "${BASH_VERSION:-}" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "${ZSH_VERSION:-}" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    # Check if protection already exists
    if ! grep -q "CLAUDE_CODE_USE_BEDROCK" "$SHELL_RC"; then
        echo -e "${YELLOW}Adding Bedrock protection to $SHELL_RC...${NC}"
        cat >> "$SHELL_RC" << 'EOF'

# Prevent accidental AWS Bedrock charges with Claude Code
# Documented in: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
# and https://docs.anthropic.com/en/docs/claude-code/settings
unset CLAUDE_CODE_USE_BEDROCK  # Disables Bedrock when unset (official variable)
unset AWS_BEARER_TOKEN_BEDROCK  # Removes Bedrock API key if set (official variable)
EOF
        echo -e "${GREEN}Protection added to $SHELL_RC${NC}"
    else
        echo -e "${GREEN}Protection already exists in $SHELL_RC${NC}"
    fi
fi

# 4. Create a wrapper script that ensures Claude Pro usage
WRAPPER_DIR="$HOME/.local/bin"
mkdir -p "$WRAPPER_DIR"

cat > "$WRAPPER_DIR/claude-safe" << 'EOF'
#!/bin/bash
# Safe wrapper for Claude Code that prevents Bedrock usage
# Variables documented at: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock

# Ensure no Bedrock variables are set
unset CLAUDE_CODE_USE_BEDROCK   # Official variable - when unset, Bedrock is disabled
unset AWS_BEARER_TOKEN_BEDROCK  # Official variable - removes Bedrock API key

# Check for any AWS/Bedrock environment contamination
if env | grep -q "BEDROCK"; then
    echo "WARNING: Bedrock-related environment variables detected!"
    echo "Unsetting them to prevent charges..."
    env | grep "BEDROCK" | cut -d= -f1 | while read var; do
        unset "$var"
    done
fi

# Launch Claude Code with explicit provider preference
exec claude "$@"
EOF

chmod +x "$WRAPPER_DIR/claude-safe"

echo -e "${GREEN}Created safe wrapper at $WRAPPER_DIR/claude-safe${NC}"
echo -e "${YELLOW}Consider adding alias claude='claude-safe' to your shell profile${NC}"

# 5. Show current status
echo -e "\n${YELLOW}Current Status:${NC}"
echo -n "Credentials file: "
if [ -f "$CREDS_FILE" ]; then
    if grep -q "claudeAiOauth" "$CREDS_FILE" 2>/dev/null; then
        echo -e "${GREEN}Claude Pro authenticated${NC}"
    else
        echo -e "${RED}Not authenticated${NC}"
    fi
else
    echo -e "${RED}Not found - need to login${NC}"
fi

echo -n "Bedrock env vars: "
if env | grep -q "BEDROCK"; then
    echo -e "${RED}FOUND - will cause charges!${NC}"
else
    echo -e "${GREEN}None found${NC}"
fi

echo -e "\n${GREEN}Protection measures in place!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run: source $SHELL_RC"
echo "2. Use 'claude-safe' instead of 'claude' or add the alias"
echo "3. If credentials were removed, run: claude-safe && /login"