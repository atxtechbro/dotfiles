DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'

# Amazon Q trusted tools (mirrors Claude's .claude/settings.json trusted tools)
TRUSTED_TOOLS="mcp__git__git_status,mcp__git__git_diff,mcp__git__git_diff_staged,mcp__git__git_diff_unstaged,mcp__git__git_log,mcp__git__git_show,mcp__git__git_fetch,mcp__git__git_branch,mcp__git__git_blame,mcp__git__git_describe,mcp__git__git_shortlog,mcp__git__git_reflog,mcp__git__git_worktree_list,mcp__git__git_remote,mcp__git__git_add,mcp__git__git_commit,mcp__git__git_checkout,mcp__git__git_create_branch,mcp__git__git_stash,mcp__git__git_stash_pop,mcp__github-read,mcp__brave-search,mcp__filesystem,mcp__awslabs.aws-documentation-mcp-server,mcp__gdrive"

# Add work-specific tools if on work machine
if [ "${WORK_MACHINE:-false}" = "true" ]; then
    TRUSTED_TOOLS="$TRUSTED_TOOLS,mcp__atlassian,mcp__gitlab"
fi

alias q='q chat --trust-tools="$TRUSTED_TOOLS" --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'