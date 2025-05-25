# MCP Server Environment Controls
# Add this to your .bashrc or .zshrc

# Detect environment based on hostname
if [[ "$(hostname)" != *"work"* ]]; then
  # On personal computer, disable work-specific MCP servers
  export MCP_DISABLE_ATLASSIAN=true
  # Add other servers to disable as needed
fi

# Optional: Allow manual override
# export MCP_DISABLE_ATLASSIAN=false # Uncomment to override

# Alias for Amazon Q with environment-aware MCP configuration
alias q="$HOME/dotfiles/bin/mcp-wrapper.sh"