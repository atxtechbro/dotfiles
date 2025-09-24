# Command Lexicon

Provider-agnostic mapping from natural language commands to procedures. Enables using the same commands in Claude Code and OpenAI Codex without relying on provider-specific slash commands.

## close-issue
- Intent: Complete and implement a GitHub issue and open a PR that references the issue.
- Invocation: "close-issue <number>" (also accepts "close issue <number>")
- Arguments:
  - <number>: GitHub issue number (parsing rule: the first integer token after the command phrase)
- Variants:
  - "close issue 123"
  - "close-issue 123"
  - "use the close-issue procedure to close GitHub issue 123"
  - "please close issue #123"
- Procedure: [close-issue-procedure.md](close-issue-procedure.md)
- Provider notes:
  - Use absolute paths and follow the Git Worktree Workflow
  - Ensure PR title/body reference "Closes #<number>"

