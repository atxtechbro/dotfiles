Close GitHub issue #{{ ARGUMENTS }}

Repository: atxtechbro/dotfiles

## Principles
{{ INJECT:principles/do-dont-explain.md }}

## Steps
1. Review issue details: `mcp__github__get_issue` for issue #{{ ARGUMENTS }}
2. Add a concise closing comment: `mcp__github__add_issue_comment`
3. Close the issue: `mcp__github__update_issue` with state "closed"
4. Verify closure succeeded

Execute immediately. Be concise in the closing comment.