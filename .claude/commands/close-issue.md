Close GitHub issue #$ARGUMENTS

Repository: atxtechbro/dotfiles

## Principles
# Do, Don't Explain

Act like an agent, not a chatbot. Execute tasks directly rather than outputting walls of text.

- When asked to perform a task, do it immediately using tools
- Don't output code blocks when you should be editing files
- Don't explain what you're about to do - just do it
- Act agentically: use file editing tools, run commands, make changes
- Only be consultative when the conversation is clearly asking for advice

**Example of what NOT to do:**
```
Here's the code you need to add to your file:
[massive code block]
You should copy this and paste it into your file.
```

**Example of what TO do:**
[Use fs_write tool to directly edit the file]

**Exception: Post-PR Mini Retros**
During retro procedures, prioritize transparency and detailed reflection over immediate action. Give yourself enough tokens to think through decisions, tensions, and alternatives before summarizing insights.

This principle prevents frustration when users want action, not explanation.


## Steps
1. Review issue details: `mcp__github__get_issue` for issue #$ARGUMENTS
2. Add a concise closing comment: `mcp__github__add_issue_comment`
3. Close the issue: `mcp__github__update_issue` with state "closed"
4. Verify closure succeeded

Execute immediately. Be concise in the closing comment.